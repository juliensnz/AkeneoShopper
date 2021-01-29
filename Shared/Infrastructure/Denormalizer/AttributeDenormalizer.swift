//
//  CategoryDenormalizer.swift
//  AkeneoShopper (iOS)
//
//  Created by Julien Sanchez on 22/01/2021.
//

import SwiftyJSON

class AttributeDenormalizer {
  class func denormalizeAll(data: JSON) -> [Attribute] {
    let path: [JSONSubscriptType] = ["_embedded","items"]
    let items = data[path].arrayValue;
    
    return items.map({ (attribute) -> Attribute in
      return Attribute(
        code: attribute["code"].string ?? "",
        labels: (attribute["labels"].dictionary ?? [:]).mapValues({ value in
          return value.string ?? ""
        }),
        type: attribute["type"].string ?? "",
        valuePerChannel: attribute["scopable"].bool ?? false,
        valuePerLocale: attribute["localizable"].bool ?? false
      )
    })
  }
}
