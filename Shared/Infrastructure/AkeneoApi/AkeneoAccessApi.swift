//
//  AkeneoFamilyApi.swift
//  AkeneoShopper (iOS)
//
//  Created by Julien Sanchez on 15/01/2021.
//

import SwiftUI
import Combine
import SDWebImageSwiftUI

class AkeneoAccessApi: Cancellable {
  @AppStorage("baseUrl") public private(set) var baseUrl = ""
  @AppStorage("clientID") private var clientID = ""
  @AppStorage("secret") private var secret = ""
  @AppStorage("user") private var user = ""
  @AppStorage("password") private var password = ""
  
  @Published var accessToken: String? = nil;
  var validUntil: Date? = nil;
  var isLoading = false;
  
  var cancellableSet = Set<AnyCancellable>()
  func cancel() {
    self.cancellableSet.forEach { (cancellable) in
      cancellable.cancel()
    }
  }
  
  func getAccessToken(force: Bool = false) -> AnyPublisher<String, ApiError> {
    let isInvalid = nil == validUntil || validUntil!.timeIntervalSinceReferenceDate - Date().timeIntervalSinceReferenceDate > 0;
    
    if (force || (!self.isLoading && isInvalid)) {
      self.isLoading = true
      Future { promise in
        self.fetchAccessToken(force: force) { (accessToken) in
          DispatchQueue.main.async {
            SDWebImageDownloader.shared.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            
            promise(.success(accessToken))
          }
        } onFailure: { (message) in
          DispatchQueue.main.async {
            promise(.failure(ApiError.badAuth(message: message)))
          }
        }
      }
      .replaceError(with: nil)
      .eraseToAnyPublisher()
      .assign(to: \.accessToken, on: self)
      .store(in: &cancellableSet)
    }
    
    return self.$accessToken
      .drop(while: { (token) -> Bool in
        return nil == token;
      })
      .setFailureType(to: ApiError.self)
      .flatMap({ accessToken -> AnyPublisher<String, ApiError> in
        return Just(accessToken!)
          .setFailureType(to: ApiError.self)
          .eraseToAnyPublisher();
      })
      .eraseToAnyPublisher()
  }
  
  public func updateAccessToken() {
    //_ = self.getAccessToken(force: true);
  }
  
  private func fetchAccessToken(force: Bool = false, onSuccess: @escaping(String) -> (), onFailure: @escaping(String) -> ()) {
    let authUrl = "\(self.baseUrl)/api/oauth/v1/token";
    guard let url = URL(string: authUrl) else {
      onFailure("Cannot generate url: \(authUrl)")
      
      return
    }
    var urlRequest = URLRequest(url: url);
    
    let clientIdAndSecret = "\(self.clientID):\(self.secret)".data(using: String.Encoding.utf8);
    guard let base64ClientIdAndSecret = clientIdAndSecret?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0)) else {
      onFailure("Cannot encode base64 client id and secret")
      
      return
    }
    
    urlRequest.setValue("Basic \(base64ClientIdAndSecret)", forHTTPHeaderField: "Authorization")
    urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
    urlRequest.httpMethod = "POST"
    let parameters: [String: Any] = [
      "username": self.user,
      "password": self.password,
      "grant_type": "password"
    ]
    urlRequest.httpBody = try! JSONSerialization.data(withJSONObject: parameters)
    
    URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
      let result = ResponseHandler.handleResponse(data: data, response: response, error: error)
      print("Error updating access token: \(String(describing: error?.localizedDescription))")
      
      switch (result) {
      case ApiResponse.success(let data):
        self.accessToken = data["access_token"].string ?? "";
        self.validUntil = Calendar.current.date(
          byAdding: .second,
          value: 3600,
          to: Date())
        onSuccess(data["access_token"].string ?? "");
      case ApiResponse.error(let error):
        print("Error updating access token: \(String(describing: error))")
        onFailure(error)
      }
    }.resume();
  }
}
