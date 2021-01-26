//
//  ProductListStore.swift
//  AkeneoShopper (iOS)
//
//  Created by Julien Sanchez on 15/01/2021.
//

import SwiftUI
import Combine

class ProductListStore: ObservableObject, Cancellable {
  @Published var catalogContext: CatalogContext;
  @Published var products: [Product];
  
  init(defaultProducts: [Product] = [], catalogContext: CatalogContext) {
    self.products = defaultProducts;
    self.catalogContext = catalogContext;
    
    AkeneoApi.sharedInstance.product.search(context: catalogContext)
      .assign(to: \.products, on: self)
      .store(in: &cancellableSet)
  }
  
  var cancellableSet = Set<AnyCancellable>()
  func cancel() {
    self.cancellableSet.forEach { (cancellable) in
      cancellable.cancel()
    }
  }
}
