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
  @Published var valueFilters: [ValueFilter];
  
  init(defaultProducts: [Product] = [], catalogContext: CatalogContext, valueFilters: [ValueFilter]) {
    self.products = defaultProducts;
    self.catalogContext = catalogContext;
    self.valueFilters = valueFilters;
    
    self.$valueFilters
      .combineLatest(self.$catalogContext)
      .flatMap { (valueFilters, catalogContext) in
        return AkeneoApi.sharedInstance.product.search(context: catalogContext, valueFilters: valueFilters)
          .replaceError(with: [])
          .eraseToAnyPublisher();
      }
      .replaceError(with: [])
      .assign(to: \.products, on: self)
      .store(in: &cancellableSet)
  }
  
  func addFilter(filter: ValueFilter)
  {
    self.valueFilters = self.valueFilters.filter { (current) -> Bool in
      return current.attribute.code != filter.attribute.code
    } + [filter];
  }
  
  func removeFilter(filter: ValueFilter)
  {
    self.valueFilters = self.valueFilters.filter { (current) -> Bool in
      return current.attribute.code != filter.attribute.code
    };
  }
  
  var cancellableSet = Set<AnyCancellable>()
  func cancel() {
    self.cancellableSet.forEach { (cancellable) in
      cancellable.cancel()
    }
  }
}
