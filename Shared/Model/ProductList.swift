//
//  ProductList.swift
//  AkeneoShopper (iOS)
//
//  Created by Julien Sanchez on 15/01/2021.
//

import SwiftUI
import SwiftyJSON

struct ProductList: Codable {
  let products: [ProductListItem];
}

struct ProductListItem: Identifiable, Codable {
  var id = UUID();
  let identifier: String;
  let label: String;
  let enabled: Bool;
  let family: Family?;
  let familyCode: String;
  let categories: [String]
  let values: [String: JSON]
  
  func getFamilyLabel(context: CatalogContext) -> String {
    guard let label = self.family?.labels[context.locale] else {
      return self.familyCode;
    }
    
    return label;
  }
  
  func getLabel(context: CatalogContext) -> String {
    guard let attributeAsLabel = self.family?.attributeAsLabel else {
      return self.identifier
    }
    
    guard let values = self.values[attributeAsLabel]?.array else {
      return self.identifier
    }
    
    guard let labelValueIndex = values.firstIndex(where: {
      return (
        nil == $0["locale"].string || $0["locale"].string == context.locale &&
        nil == $0["scope"].string || $0["scope"].string == context.channel
      )
    }) else {
      return self.identifier
    }
    
    guard let label = values[labelValueIndex]["data"].string else {
      return self.identifier
    }

    return label
  }
}
