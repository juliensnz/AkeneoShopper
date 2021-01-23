//
//  Product.swift
//  AkeneoShopper (iOS)
//
//  Created by Julien Sanchez on 22/01/2021.
//

import SwiftyJSON

class ProductDenormalizer {
  class func denormalizeAll(data: JSON, context: CatalogContext) -> [Product] {
    let path: [JSONSubscriptType] = ["_embedded","items"]
    let items = data[path].arrayValue;
    
    return items.map({ (product) -> Product in
      let familyCode = product["family"].string ?? "";
      let values = product["values"].dictionary;
      
      return Product(
        identifier: product["identifier"].string ?? "",
        enabled: product["enabled"].bool ?? true,
        familyCode: familyCode,
        categoryCodes: (product["categories"].array ?? []).map({ (category) -> String in
          return category.string ?? ""
        }),
        rawValues: values!,
        context: context
      )
    })
  }
  
  class func getFamilyCodes(data: JSON) -> [String] {
    let path: [JSONSubscriptType] = ["_embedded","items"]
    let items = data[path].arrayValue;
    
    return Array(Set(items.map({ (product) -> String in
      return product["family"].string ?? ""
    })))
  }
  
  private class func getFamily(families: [Family], code: String) -> Family? {
    if let familyIndex = families.firstIndex(where: { $0.code == code }) {
      return families[familyIndex]
    }
    
    return nil
  }
}
