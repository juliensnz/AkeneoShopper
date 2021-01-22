//
//  ProductList.swift
//  AkeneoShopper (iOS)
//
//  Created by Julien Sanchez on 15/01/2021.
//

import SwiftUI

struct Family: Identifiable, Codable {
  var id = UUID();
  let code: String;
  let labels: [String: String];
  let attributeAsLabel: String;
  let attributeAsMainImage: String;
}
