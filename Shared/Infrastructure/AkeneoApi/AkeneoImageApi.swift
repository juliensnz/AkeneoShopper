//
//  AkeneoImageApi.swift
//  AkeneoShopper (iOS)
//
//  Created by Julien Sanchez on 15/01/2021.
//

import SwiftUI
import Combine

class AkeneoImageApi {
  func get(url: String) -> AnyPublisher<UIImage?, ApiError> {
    return AkeneoApi.sharedInstance.getUrlRequest(url: url, isJson: false)
      .flatMap { urlRequest -> AnyPublisher<UIImage?, Never> in
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
          .map { data in
            print(data);
            return UIImage(data: data.data)
          }
          .mapError({ (error) -> Error in
            print(error.localizedDescription)
            return error
          })
          .replaceError(with: nil)
          .receive(on: DispatchQueue.main)
          .eraseToAnyPublisher()
      }
      .eraseToAnyPublisher()
    
//    return AkeneoApi.sharedInstance
//      .getUrlRequest(url: url)
//      .flatMap({ urlRequest in
//        return URLSession.shared.dataTaskPublisher(for: urlRequest)
//          .mapError({ (error: URLError) -> ApiError in
//            return ApiError.fetchError(message: error.localizedDescription)
//          })
//      })
//      .map({ data, response in
//        return UIImage(data: data)
//      })
//      .eraseToAnyPublisher()
  }
}
