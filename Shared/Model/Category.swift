//
//  ProductList.swift
//  AkeneoShopper (iOS)
//
//  Created by Julien Sanchez on 15/01/2021.
//

import SwiftUI

struct Category: Identifiable, Codable, Hashable {
  var id = UUID();
  let code: String;
  let labels: [String: String];
}
