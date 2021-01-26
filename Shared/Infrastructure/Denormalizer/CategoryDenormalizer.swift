//
//  CategoryDenormalizer.swift
//  AkeneoShopper (iOS)
//
//  Created by Julien Sanchez on 22/01/2021.
//

import SwiftyJSON

class CategoryDenormalizer {
  class func denormalizeAll(data: JSON) -> [Category] {
    let path: [JSONSubscriptType] = ["_embedded","items"]
    let items = data[path].arrayValue;
    
    return items.map({ (category) -> Category in
      return Category(
        code: category["code"].string ?? "",
        labels: (category["labels"].dictionary ?? [:]).mapValues({ value in
          return value.string ?? ""
        })
      )
    })
  }
}
