//
//  AkeneoApi.swift
//  AkeneoShopper (iOS)
//
//  Created by Julien Sanchez on 15/01/2021.
//

import SwiftUI
import SwiftyJSON
import Combine
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

enum ApiError: Error {
  case badAuth(message: String)
  case impossibleToParse(message: String)
  case fetchError(message: String)
  case badUrl(message: String)
}

class AkeneoApi: Cancellable {
  
  
  static let sharedInstance = AkeneoApi()
  
  var cancellableSet = Set<AnyCancellable>()
  func cancel() {
    self.cancellableSet.forEach { (cancellable) in
      cancellable.cancel()
    }
  }
  
  let family: AkeneoFamilyApi;
  let product: AkeneoProductApi;
  let category: AkeneoCategoryApi;
  let attribute: AkeneoAttributeApi;
  let image: AkeneoImageApi;
  let access: AkeneoAccessApi;
  
  init() {
    self.family = AkeneoFamilyApi();
    self.product = AkeneoProductApi();
    self.category = AkeneoCategoryApi();
    self.attribute = AkeneoAttributeApi();
    self.image = AkeneoImageApi();
    self.access = AkeneoAccessApi();
  }
  
  func getUrl(url: String) -> AnyPublisher<URL, ApiError> {
    let fullUrl = url.starts(with: self.access.baseUrl) ?
      url :
      "\(self.access.baseUrl)\(url)";
    
    guard let validUrl = URL(string: fullUrl) else {
      return Fail<URL, ApiError>(error: ApiError.badUrl(message: "Invalid URL: \(url)"))
        .eraseToAnyPublisher()
    }
    
    //https://stackoverflow.com/questions/57543855/using-just-with-flatmap-produce-failure-mismatch-combine
    return Just(validUrl)
      .setFailureType(to: ApiError.self)
      .eraseToAnyPublisher()
  }
  
  func getUrlRequest(url: String) -> AnyPublisher<URLRequest, ApiError> {
    return self.getUrl(url: url)
      .flatMap { validUrl in
        return self.getUrlRequest(url: validUrl)
      }
      .eraseToAnyPublisher()
  }
  
  func getUrlRequest(url: URL) -> AnyPublisher<URLRequest, ApiError> {
    return self.access.getAccessToken()
      .map { (accessToken) -> URLRequest in
        var urlRequest = URLRequest(url: url);
        urlRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return urlRequest
      }
      .eraseToAnyPublisher()
  }
  
  public func get(url: String) -> AnyPublisher<JSON, ApiError> {
    return self.getUrl(url: url)
      .flatMap { validUrl in
        return self.get(url: validUrl)
      }
      .eraseToAnyPublisher()
  }
  
  public func get(url: URL) -> AnyPublisher<JSON, ApiError> {
    return self.getUrlRequest(url: url)
      .flatMap { urlRequest in
        return Future<JSON, ApiError> { promise in
          URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            let result = ResponseHandler.handleResponse(data: data, response: response, error: error)
            
            switch (result) {
            case ApiResponse.success(let successData):
              DispatchQueue.main.async {
                promise(.success(successData))
              }
            case ApiResponse.error(let errorMessage):
              DispatchQueue.main.async {
                promise(.failure(ApiError.fetchError(message: errorMessage)))
              }
            }
          }.resume();
        }
        .eraseToAnyPublisher()
      }
      .eraseToAnyPublisher()
  }
}
