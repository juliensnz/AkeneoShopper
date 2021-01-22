//
//  Product.swift
//  AkeneoShopper (iOS)
//
//  Created by Julien Sanchez on 22/01/2021.
//

import SwiftyJSON

class ProductDenormalizer {
  class func denormalizeAll(data: JSON, families: [Family], context: CatalogContext) -> [ProductListItem] {
    let path: [JSONSubscriptType] = ["_embedded","items"]
    let items = data[path].arrayValue;
    
    return items.map({ (product) -> ProductListItem in
      let familyCode = product["family"].string ?? "";
      let family = self.getFamily(families: families, code: familyCode);
      let values = product["values"].dictionary as? [String: JSON];
      
      return ProductListItem(
        identifier: product["identifier"].string ?? "",
        label: product["identifier"].string ?? "",
        enabled: product["enabled"].bool ?? true,
        family: family,
        familyCode: familyCode,
        categories: (product["categories"].array ?? []).map({ (category) -> String in
          return category.string ?? ""
        }),
        values: values!
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
