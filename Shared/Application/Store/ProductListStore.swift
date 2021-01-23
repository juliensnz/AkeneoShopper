//
//  ProductListStore.swift
//  AkeneoShopper (iOS)
//
//  Created by Julien Sanchez on 15/01/2021.
//

import SwiftUI
import Combine

class ProductListStore: ObservableObject {
  @Published var products: [ProductHeaderModel];
  
  init(defaultProducts: [ProductHeaderModel] = []) {
    self.products = defaultProducts;
    
    self.getProductList()
  }
  
  func getProductList() {
    AkeneoApi.sharedInstance.getAllProducts(context: catalogContext, onSuccess: { (productList) in
      self.products = productList.products.map({ (product) -> ProductHeaderModel in
        return ProductHeaderModel(product: product, context: catalogContext)
      });
    }, onFailure: {error in
      print(error)
    })
  }
}
