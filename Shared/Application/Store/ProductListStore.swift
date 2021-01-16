//
//  ProductListStore.swift
//  AkeneoShopper (iOS)
//
//  Created by Julien Sanchez on 15/01/2021.
//

import SwiftUI
import Combine

class ProductListStore: ObservableObject {
  @Published var productList: ProductList;
  
  init(defaultProducts: ProductList = ProductList(products: [])) {
    self.productList = defaultProducts;
    
//    self.getProductList()
  }
  
  func getProductList() {
    AkeneoApi().getAllProducts { (productList) in
      self.productList = productList;
    }
  }
}
