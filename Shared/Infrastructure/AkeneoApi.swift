//
//  AkeneoApi.swift
//  AkeneoShopper (iOS)
//
//  Created by Julien Sanchez on 15/01/2021.
//

import SwiftUI
import SwiftyJSON
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

class AkeneoApi {
  let baseUrl = "http://192.168.1.23:8080"
  let clientID = "1_16d23okvhfb44ccgo8s4wgoo8swocokcgsk0c0o4c084k00ks4"
  let secret = "2crnhds1wx5wocwsg4sw0cgwo0w0sckwcokg8go4sck8c44cso"
  let user = "magento_0000"
  let password = "2dpuj5tx4w4d"
  
  var accessToken: String? = nil;
  var validUntil: Date? = nil;
  
  static let sharedInstance = AkeneoApi()
  
  private func getAccessToken(force: Bool = false, onSuccess: @escaping(String) -> (), onFailure: @escaping(String) -> ()) {
    if (!force && accessToken != nil && validUntil != nil && Date().compare(validUntil!).rawValue > 0) {
      onSuccess(accessToken!)
    }
    
    guard let url = URL(string: "\(self.baseUrl)/api/oauth/v1/token") else { return }
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
  
  private func getUrlRequest(url: URL, onSuccess: @escaping(URLRequest) -> (), onFailure: @escaping(String) -> ()) {
    self.getAccessToken(onSuccess: { (accessToken) in
      
      var urlRequest = URLRequest(url: url);
      urlRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
      urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

      onSuccess(urlRequest)
    }, onFailure: onFailure)
  }
  
  private func get(url: String, onSuccess: @escaping(JSON) -> (), onFailure: @escaping(String) -> ()) {
    guard let validUrl = URL(string: url) else {
      onFailure("Invalid URL: \(url)");
      return
    }
    
    self.get(url: validUrl, onSuccess: onSuccess, onFailure: onFailure)
  }
  
  private func get(url: URL, onSuccess: @escaping(JSON) -> (), onFailure: @escaping(String) -> ()) {
    self.getUrlRequest(url: url, onSuccess: { (urlRequest) in
      URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
        let result = ResponseHandler.handleResponse(data: data, response: response, error: error)
                
        switch (result) {
        case ApiResponse.success(let successData):
          onSuccess(successData)
        case ApiResponse.error(let errorMessage):
          onFailure(errorMessage)
        }
      }.resume();
    }, onFailure: onFailure)
  }
  
  func getAllProducts(context: CatalogContext, onSuccess: @escaping (ProductList) -> (), onFailure: @escaping(String) -> ()) {
    self.get(url: "\(self.baseUrl)/api/rest/v1/products", onSuccess: { (data) in
//      let familyCodes = ProductDenormalizer.getFamilyCodes(data: data)
      
//      self.getFamiliesByCode(familyCodes: familyCodes, onSuccess: { families in
        onSuccess(ProductList(products: ProductDenormalizer.denormalizeAll(data: data, context: context)))
//      }, onFailure: onFailure)
      
    }, onFailure: onFailure)
  }
  
  func getFamiliesByCode(familyCodes: [String], onSuccess: @escaping ([Family]) -> (), onFailure: @escaping(String) -> ()) {
    let joinedFamilyCodes = familyCodes.map({ #""\#($0)""# }).joined(separator: ",")
    let search = #"{"code":[{"operator":"IN","value":[\#(joinedFamilyCodes)]}]}"#
    
    let url = "\(self.baseUrl)/api/rest/v1/families";
    guard var validUrl = URLComponents(string: url) else {
      onFailure("Invalid URL: \(url)");
      return
    }
    validUrl.queryItems = [
      URLQueryItem(name: "search", value: search)
    ]
    
    self.get(url: validUrl.url!, onSuccess: { (data) in
      onSuccess(FamilyDenormalizer.denormalizeAll(data: data))
    }, onFailure: onFailure)
  }
  
  func getFamily(code: String, onSuccess: @escaping (Family) -> (), onFailure: @escaping(String) -> ()) {
    let joinedFamilyCodes = [code].map({ #""\#($0)""# }).joined(separator: ",")
    let search = #"{"code":[{"operator":"IN","value":[\#(joinedFamilyCodes)]}]}"#
    
    let url = "\(self.baseUrl)/api/rest/v1/families";
    guard var validUrl = URLComponents(string: url) else {
      onFailure("Invalid URL: \(url)");
      return
    }
    validUrl.queryItems = [
      URLQueryItem(name: "search", value: search)
    ]
    
    self.get(url: validUrl.url!, onSuccess: { (data) in
      onSuccess(FamilyDenormalizer.denormalizeAll(data: data)[0])
    }, onFailure: onFailure)
  }
  
  func loadImage(url: URL, onSuccess: @escaping (URLSession.DataTaskPublisher) -> (), onFailure: @escaping(String) -> ()) {
    self.getUrlRequest(url: url, onSuccess: { request in
      onSuccess(URLSession.shared.dataTaskPublisher(for: request))
    }, onFailure: onFailure)
  }
}
