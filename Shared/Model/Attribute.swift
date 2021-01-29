//
//  ProductList.swift
//  AkeneoShopper (iOS)
//
//  Created by Julien Sanchez on 15/01/2021.
//

import Foundation

struct Attribute: Identifiable, Codable, Hashable {
  var id = UUID();
  let code: String;
  let labels: [String: String];
  let type: String;
  let valuePerChannel: Bool;
  let valuePerLocale: Bool;
}
