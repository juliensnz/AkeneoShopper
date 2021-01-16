//
//  AkeneoApi.swift
//  AkeneoShopper (iOS)
//
//  Created by Julien Sanchez on 15/01/2021.
//

import SwiftUI

struct AkeneoApiAuthorizationResponse: Codable {
  let access_token: String;
  let expires_in: Int;
  let refresh_token: String;
}

struct AkeneoApiProduct: Codable {
  let identifier: String;
  let enabled: Bool;
  let family: String;
  let categories: [String]
}

struct AkeneoApiProductList: Codable {
  let items: [AkeneoApiProduct]
}

struct AkeneoApiProductListResponse: Codable {
  let _embedded: AkeneoApiProductList;
}

enum ApiError: Error {
  case authentication(message: String)
}

class AkeneoApi {
  let baseUrl = "http://pcd.test:8080"
  let clientID = "5_3zbhbmi3p88wks4g4sw0g40occ8gk4skwc4s40k4kkwc044gs0"
  let secret = "4g31gvvkw54w4k40ws0o0sck040oog8k844ogcc8ogs44w0o4g"
  let user = "swift_2340"
  let password = "51c0630bd"
  
  var accessToken: String? = nil;
  var validUntil: Date? = nil;
  
  func getAccessToken(force: Bool = false, completion: @escaping (String) -> ()) {
    if (!force && accessToken != nil && validUntil != nil && Date().compare(validUntil!).rawValue > 0) {
      completion(accessToken!)
    }
    
    guard let url = URL(string: "\(self.baseUrl)/api/oauth/v1/token") else { return }
    var urlRequest = URLRequest(url: url);
    
    let clientIdAndSecret = "\(self.clientID):\(self.secret)".data(using: String.Encoding.utf8);
    guard let base64ClientIdAndSecret = clientIdAndSecret?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0)) else {
      print("Cannot encode base64 client id and secret")
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

    URLSession.shared.dataTask(with: urlRequest) { (data, _, _) in
      guard let data = data else { return }

      do {
        let authorization = try JSONDecoder().decode(AkeneoApiAuthorizationResponse.self, from: data);
        
        DispatchQueue.main.async {
          self.accessToken = authorization.access_token;
          self.validUntil = Calendar.current.date(
            byAdding: .hour,
            value: 1,
            to: Date())
          
          completion(authorization.access_token);
        }
      } catch {
        print(error)
      }
    }.resume();
  }
  
  func getAllProducts(completion: @escaping (ProductList) -> ()) {
    self.getAccessToken { (accessToken) in
      guard let url = URL(string: "http://pcd.test:8080/api/rest/v1/products") else { return }
      var urlRequest = URLRequest(url: url);
      urlRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
      urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

      URLSession.shared.dataTask(with: urlRequest) { (data, _, _) in
        guard let data = data else { return }

        do {
          let products = try JSONDecoder().decode(AkeneoApiProductListResponse.self, from: data);
          
          DispatchQueue.main.async {
            completion(ProductList(products: products._embedded.items.map({ (apiProduct: AkeneoApiProduct) -> ProductListItem in
              return ProductListItem(apiProduct: apiProduct)
            })));
          }
        } catch {
          print(error)
        }
      }.resume();
    }
  }
}
