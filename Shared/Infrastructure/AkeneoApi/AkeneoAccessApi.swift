//
//  AkeneoFamilyApi.swift
//  AkeneoShopper (iOS)
//
//  Created by Julien Sanchez on 15/01/2021.
//

import SwiftUI
import Combine

class AkeneoAccessApi: Cancellable {
  @AppStorage("baseUrl") public private(set) var baseUrl = ""
  @AppStorage("clientID") private var clientID = ""
  @AppStorage("secret") private var secret = ""
  @AppStorage("user") private var user = ""
  @AppStorage("password") private var password = ""
  
  var accessToken: String? = nil;
  var validUntil: Date? = nil;
  
  var cancellableSet = Set<AnyCancellable>()
  func cancel() {
    self.cancellableSet.forEach { (cancellable) in
      cancellable.cancel()
    }
  }
  
  func getAccessToken(force: Bool = false) -> AnyPublisher<String, ApiError> {
    return Future { promise in
      self.fetchAccessToken(force: force) { (accessToken) in
        promise(.success(accessToken))
      } onFailure: { (message) in
        promise(.failure(ApiError.badAuth(message: message)))
      }
    }.eraseToAnyPublisher()
  }
  
  private func fetchAccessToken(force: Bool = false, onSuccess: @escaping(String) -> (), onFailure: @escaping(String) -> ()) {
    if (!force && accessToken != nil && validUntil != nil && Date().compare(validUntil!).rawValue > 0) {
      onSuccess(accessToken!)
    }
    
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
        
      switch (result) {
      case ApiResponse.success(let data):
        self.accessToken = data["access_token"].string ?? "";
        self.validUntil = Calendar.current.date(
          byAdding: .hour,
          value: 1,
          to: Date())
        
        onSuccess(data["access_token"].string ?? "");
      case ApiResponse.error(let error):
        onFailure(error)
      }
    }.resume();
  }
}
