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
  @Published var products: [Product] = []
  
  var cancellableSet = Set<AnyCancellable>()
  func cancel() {
    self.cancellableSet.forEach { (cancellable) in
      cancellable.cancel()
    }
  }
  
  init() {
    self.context = nil
    
    self.$context
      .receive(on: RunLoop.main)
      .filter({ (context) -> Bool in
        return nil != context
      })
      .debounce(for: 0.1, scheduler: RunLoop.main)
      .removeDuplicates()
      .flatMap { context in
        return AkeneoApi.sharedInstance.get(url: "/api/rest/v1/products")
          .catch { error in return Just([]) }
          .map({ data -> [Product] in
            return ProductDenormalizer.denormalizeAll(data: data, context: context!)
          })
          .eraseToAnyPublisher()
        
        
//        return Future { promise in
//          self.getAllProducts(context: context!) { (products) in
//            DispatchQueue.main.async {
//              promise(.success(products))
//            }
//          } onFailure: { (error) in
//            print(error)
//          }
//        }
      }
      .eraseToAnyPublisher()
      .assign(to: \.products, on: self)
      .store(in: &cancellableSet)
  }
  
//  func getAllProducts(context: CatalogContext, onSuccess: @escaping ([Product]) -> (), onFailure: @escaping(String) -> ()) {
//    AkeneoApi.sharedInstance.get(url: "/api/rest/v1/products", onSuccess: { (data) in
//      onSuccess(ProductDenormalizer.denormalizeAll(data: data, context: context))
//    }, onFailure: onFailure)
//  }
  
  func search(context: CatalogContext) -> Published<[Product]>.Publisher {
    self.context = context
    
    return self.$products
  }
}
