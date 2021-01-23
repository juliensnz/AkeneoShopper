//
//  FamilyDenormalizer.swift
//  AkeneoShopper (iOS)
//
//  Created by Julien Sanchez on 22/01/2021.
//

import SwiftyJSON

class FamilyDenormalizer {
  class func denormalizeAll(data: JSON) -> [Family] {
    let path: [JSONSubscriptType] = ["_embedded","items"]
    let items = data[path].arrayValue;
    
    return items.map({ (family) -> Family in
      return Family(
        code: family["code"].string ?? "",
        labels: (family["labels"].dictionary ?? [:]).mapValues({ value in
          return value.string ?? ""
        }),
        attributeAsLabel: family["attribute_as_label"].string ?? "",
        attributeAsMainImage: family["attribute_as_image"].string ?? ""
      )
    })
  }
}
