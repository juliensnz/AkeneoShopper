//
//  ProductValue.swift
//  AkeneoShopper
//
//  Created by Julien Sanchez on 27/01/2021.
//

import Foundation
import SwiftyJSON

enum ProductValueType {
  case text;
  case image;
}

protocol ProductValue {
  var type: ProductValueType { get };
  var attribute: Attribute { get }
  var channel: String? { get };
  var locale: String? { get };
  func stringValue() -> String
  func match(attribute: Attribute, context: CatalogContext) -> Bool
  func uniqueId() -> String
}

extension ProductValue {
  func match(attribute: Attribute, context: CatalogContext) -> Bool {
    let channelMatches = !attribute.valuePerChannel || self.channel == context.channel
    let localeMatches = !attribute.valuePerLocale || self.locale == context.locale
    
    return channelMatches && localeMatches && attribute.code == self.attribute.code
  }
  
  func uniqueId() -> String {
    let locale = nil == self.locale ? "" : "-" + (self.locale ?? "")
    let channel = nil == self.channel ? "" : "-" + (self.channel ?? "")
    
    return "\(self.attribute.code)\(locale)\(channel)"
  }
}

//https://stackoverflow.com/questions/39048963/creating-a-protocol-that-represents-hashable-objects-that-can-be-on-or-off
struct IdentifiableProductValue: ProductValue, Identifiable {
  let id = UUID();
  let value: ProductValue;
  
  var type: ProductValueType { get {
    return self.value.type
  } };
  var attribute: Attribute { get {
    return self.value.attribute
  } }
  var channel: String? { get {
    return self.value.channel
  } };
  var locale: String? { get {
    return self.value.locale
  } };
  func stringValue() -> String {
    return self.value.stringValue()
  }
}

class TextProductValue: ProductValue {
  let type = ProductValueType.text
  let attribute: Attribute
  let channel: String?;
  let locale: String?;
  let text: String;
  
  init(attribute: Attribute, channel: String?, locale: String?, text: String) {
    self.attribute = attribute
    self.channel = channel
    self.locale = locale
    self.text = text
  }
  
  func stringValue() -> String {
    return text
  }
}

class ImageProductValue: ProductValue {
  let type = ProductValueType.text
  let attribute: Attribute
  let channel: String?;
  let locale: String?;
  let code: String;
  let href: String;
  
  init(attribute: Attribute, channel: String?, locale: String?, code: String, href: String) {
    self.attribute = attribute
    self.channel = channel
    self.locale = locale
    self.code = code
    self.href = href
  }
  
  func stringValue() -> String {
    return code
  }
}

func createValuesFromRawValues(attributes: [Attribute], rawValues: [String: JSON]) -> [IdentifiableProductValue] {
  let valueKeys = Array(rawValues.keys);
  
  return valueKeys.reduce([IdentifiableProductValue]()) { result, attributeCode in
    guard let attributeValues = rawValues[attributeCode],
          let values = attributeValues.array else {
      return result
    }
    
    return result + values.map({ value -> IdentifiableProductValue? in
      guard let attribute = attributes.first(where: { $0.code == attributeCode}) else {
        return nil
      }
      
      let channel = value["scope"].string
      let locale = value["locale"].string
      
      switch attribute.type {
      case "pim_catalog_text":
        guard let text = value["data"].string else {
          return nil
        }
        
        return IdentifiableProductValue(value: TextProductValue(attribute: attribute, channel: channel, locale: locale, text: text))
      case "pim_catalog_textarea":
        guard let text = value["data"].string else {
          return nil
        }
        
        return IdentifiableProductValue(value: TextProductValue(attribute: attribute, channel: channel, locale: locale, text: text))
      case "pim_catalog_image":
        guard let code = value["data"].string else {
          return nil
        }
        guard let href = value["_links"]["download"]["href"].string else {
          return nil
        }
        
        return IdentifiableProductValue(value: ImageProductValue(attribute: attribute, channel: channel, locale: locale, code: code, href: href))
      default:
        return nil
      }
    }).compactMap { $0 }
  }
}
