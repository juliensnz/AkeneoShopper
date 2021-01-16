//
//  ProductList.swift
//  AkeneoShopper (iOS)
//
//  Created by Julien Sanchez on 15/01/2021.
//

import SwiftUI

struct ProductList: Codable {
  let products: [ProductListItem];
}

struct ProductListItem: Identifiable, Codable {
  let id: String;
  let identifier: String;
  let label: String;
  let enabled: Bool;
  let family: String;
  let categories: [String]
  
  init(apiProduct: AkeneoApiProduct) {
    self.id = apiProduct.identifier;
    self.identifier = apiProduct.identifier;
    self.label = apiProduct.identifier;
    self.enabled = apiProduct.enabled;
    self.family = apiProduct.family;
    self.categories = apiProduct.categories;
  }
  
  init(
    id: String,
    identifier: String,
    label: String,
    enabled: Bool,
    family: String,
    categories: [String]
  ) {
    self.id = id;
    self.identifier = identifier;
    self.label = label;
    self.enabled = enabled;
    self.family = family;
    self.categories = categories;
  }
}
