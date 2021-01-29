//
//  ValueFilter.swift
//  AkeneoShopper
//
//  Created by Julien Sanchez on 27/01/2021.
//

import Foundation

enum ValueFilterType {
  case text;
  case image;
}

enum Operator: String {
  case equal = "=";
}

protocol ValueFilter {
  var id: UUID { get };
  var type: ValueFilterType { get };
  var attribute: Attribute { get }
  var filter: Operator {get};
  func stringValue() -> String
  func encode() -> String
  func match(attribute: Attribute) -> Bool
}

extension ValueFilter {
  func match(attribute: Attribute) -> Bool {
    return attribute.code == self.attribute.code
  }
}

class TextValueFilter: ValueFilter {
  let id = UUID()
  let type = ValueFilterType.text
  let attribute: Attribute
  let value: String;
  let filter: Operator;
  
  init(attribute: Attribute, filter: Operator, value: String) {
    self.attribute = attribute;
    self.filter = filter;
    self.value = value;
  }
  
  func stringValue() -> String {
    return value
  }
  
  func encode() -> String {
    return #"{"\#(self.attribute.code)":[{"operator":"\#(self.filter.rawValue)","value":"\#(self.value)"}]}"#
  }
}

func encodeFilters (valueFilters: [ValueFilter]) -> String {
  return valueFilters.map { (valueFilter) -> String in
    return valueFilter.encode();
  }.joined(separator: ",")
}
