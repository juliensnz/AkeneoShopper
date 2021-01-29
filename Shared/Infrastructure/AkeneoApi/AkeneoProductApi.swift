//
//  AkeneoProductApi.swift
//  AkeneoShopper (iOS)
//
//  Created by Julien Sanchez on 15/01/2021.
//

import SwiftUI
import Combine

class AkeneoProductApi: Cancellable {
  @Published var context: CatalogContext?;
  @Published var valueFilters: [ValueFilter];
  @Published var products: [Product] = []
  
  var cancellableSet = Set<AnyCancellable>()
  func cancel() {
    self.cancellableSet.forEach { (cancellable) in
      cancellable.cancel()
    }
  }
  
  init() {
    self.context = nil
    self.valueFilters = []
    
    self.$context
      .receive(on: RunLoop.main)
      .filter({ (context) -> Bool in
        return nil != context
      })
      .debounce(for: 0.1, scheduler: RunLoop.main)
      .removeDuplicates()
      .combineLatest(self.$valueFilters)
      .flatMap { (context, valueFilters) -> AnyPublisher<[Product], ApiError> in
        let url = "\(AkeneoApi.sharedInstance.access.baseUrl)/api/rest/v1/products";
        guard var urlComponents = URLComponents(string: url) else {
          return Fail<[Product], ApiError>(error: ApiError.badUrl(message: "Invalid URL: \(url)"))
            .eraseToAnyPublisher()
        }
        
        urlComponents.queryItems = [
          URLQueryItem(name: "with_count", value: "true"),
          URLQueryItem(name: "limit", value: "100")
        ];
        
        if (!valueFilters.isEmpty) {
          urlComponents.queryItems?.append(URLQueryItem(name: "search", value: encodeFilters(valueFilters: valueFilters)))
        }
        
        guard let validUrl = urlComponents.url else {
          return Fail<[Product], ApiError>(error: ApiError.badUrl(message: "Invalid URL: \(url)"))
            .eraseToAnyPublisher()
        }
        
        return AkeneoApi.sharedInstance.get(url: validUrl)
          .mapError { error in return ApiError.fetchError(message: error.localizedDescription) }
          .map({ data -> [Product] in
            return ProductDenormalizer.denormalizeAll(data: data, context: context!)
          })
          .eraseToAnyPublisher()
      }
      .eraseToAnyPublisher()
      .replaceError(with: [])
      .assign(to: \.products, on: self)
      .store(in: &cancellableSet)
  }
  
  func search(context: CatalogContext, valueFilters: [ValueFilter]) -> Published<[Product]>.Publisher {
    self.context = context
    self.valueFilters = valueFilters
    
    return self.$products
  }
}
