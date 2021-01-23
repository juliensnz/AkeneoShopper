//
//  ProductList.swift
//  AkeneoShopper (iOS)
//
//  Created by Julien Sanchez on 15/01/2021.
//

import SwiftUI
import SwiftyJSON
import Combine
import UIKit

class ProductList {
  @Published var products: [Product] = [];
}

class Product: Identifiable {
  var id = UUID();
  @Published var context: CatalogContext;
  @Published var identifier: String;
  @Published var familyCode: String;
  @Published var rawValues: [String: JSON];
  @Published var categoryCodes: [String];
  let enabled: Bool;
  
  var family: AnyPublisher<Family, Never> {
    return $familyCode.flatMap { familyCode in
      return Future { promise in
        AkeneoApi.sharedInstance.getFamily(code: familyCode, onSuccess: { family in
          promise(.success(family))
        }, onFailure: { error in
          print(error)
        })
      }
    }.eraseToAnyPublisher()
  };
  
  var label: AnyPublisher<String, Never> {
    return self.family.combineLatest(self.$rawValues) { updatedFamily, updatedValues in
      let attributeAsMainImageCode = updatedFamily.attributeAsLabel;
      
      guard let valuesAsMainImage = updatedValues[attributeAsMainImageCode]?.array else {
        return self.identifier
      }
      
      guard let labelValueIndex = valuesAsMainImage.firstIndex(where: { value in
        return (
          nil == value["locale"].string || value["locale"].string == self.context.locale &&
          nil == value["scope"].string || value["scope"].string == self.context.channel
        )
      }) else {
        return self.identifier
      }
      
      guard let label = valuesAsMainImage[labelValueIndex]["data"].string else {
        return self.identifier
      }

      return label
    }.eraseToAnyPublisher()
  }
  
  var familyLabel: AnyPublisher<[String: String], Never> {
    return self.family.map { family in
      return family.labels
    }.eraseToAnyPublisher()
  }
  
  var values: [String: Any] = [:]
  
  init(identifier: String, enabled: Bool, familyCode: String, categoryCodes: [String], rawValues: [String: JSON], context: CatalogContext)
  {
    self.identifier = identifier;
    self.enabled = enabled;
    self.familyCode = familyCode;
    self.rawValues = rawValues;
    self.categoryCodes = categoryCodes;
    self.context = context;
  }
}
