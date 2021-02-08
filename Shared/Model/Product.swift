//
//  ProductList.swift
//  AkeneoShopper (iOS)
//
//  Created by Julien Sanchez on 15/01/2021.
//

import SwiftUI
import SwiftyJSON
import Combine

class Product: Identifiable, Cancellable, ObservableObject {
  var id = UUID();
  @Published var context: CatalogContext;
  @Published var identifier: String;
  @Published var familyCode: String;
  @Published var rawValues: [String: JSON];
  @Published var categoryCodes: [String];
  
  @Published var familyLabel: String;
  @Published var categoryLabels: [String];
  @Published var label: String;
  @Published var attributes: [Attribute]
  
  let enabled: Bool;
  let familyColor: Double
  @Published var images: [String] = []
  
  @Published var family: Family? = nil
  @Published var categories: [Category] = []
  @Published var values: [IdentifiableProductValue] = []
  
  init(identifier: String, enabled: Bool, familyCode: String, categoryCodes: [String], rawValues: [String: JSON], context: CatalogContext)
  {
    self.identifier = identifier;
    self.enabled = enabled;
    self.familyCode = familyCode;
    self.familyColor = Double(abs(familyCode.hashValue) % 1000) / 1000.0
    self.rawValues = rawValues;
    self.categoryCodes = categoryCodes;
    self.context = context;
    
    self.familyLabel = familyCode;
    self.categoryLabels = categoryCodes;
    self.label = identifier
    self.attributes = []
    self.values = []
    
    print("family hash: \(self.familyColor)")
    
    print("load product \(identifier)")
    
    self.updateFamilyOnCodeChange()
    self.updateFamilyLabelOnFamilyChange()
    self.updateLabelOnFamilyChange()
    self.updateCategoryOnCodesChange()
    self.updateCategoryLabelsOnCategoryChange()
    self.updateAttributesOnRawValueChange()
    self.updateValuesOnAttributesChange()
    self.updateImagesOnFamilyChange()
  }
  
  func updateFamilyOnCodeChange()
  {
    self.$familyCode
      .receive(on: RunLoop.main)
      .removeDuplicates()
      .flatMap { familyCode in
        return AkeneoApi.sharedInstance.family.get(code: familyCode)
      }
      .eraseToAnyPublisher()
      .assign(to: \.family, on: self)
      .store(in: &cancellableSet)
  }
  
  func updateFamilyLabelOnFamilyChange()
  {
    self.$family
      .receive(on: RunLoop.main)
      .removeDuplicates()
      .map { family in
        guard let family = family else {
          return self.familyCode
        }
        
        guard let label = family.labels[self.context.locale] else {
          return self.familyCode
        }
        
        return label
      }
      .eraseToAnyPublisher()
      .assign(to: \.familyLabel, on: self)
      .store(in: &cancellableSet)
  }
  
  func updateAttributesOnRawValueChange()
  {
    self.$rawValues
      .receive(on: RunLoop.main)
      .removeDuplicates()
      .map({ updatedValues -> [String] in
        return Array(updatedValues.keys)
      })
      .flatMap { attributeCodes in
        return AkeneoApi.sharedInstance.attribute.getByCodes(codes: attributeCodes)
      }
      .eraseToAnyPublisher()
      .assign(to: \.attributes, on: self)
      .store(in: &cancellableSet)
  }
  
  func updateValuesOnAttributesChange()
  {
    self.$attributes
      .receive(on: RunLoop.main)
      .combineLatest(self.$rawValues) { attributes, rawValues in
        let values = createValuesFromRawValues(attributes: attributes, rawValues: rawValues)
        
        return values
      }
      .eraseToAnyPublisher()
      .assign(to: \.values, on: self)
      .store(in: &cancellableSet)
  }
  
  func updateLabelOnFamilyChange()
  {
    self.$family
      .receive(on: RunLoop.main)
      .combineLatest(self.$values, self.$attributes, self.$context) { updatedFamily, updatedValues, updatedAttributes, updatedCatalogContext in
        guard let family = updatedFamily,
              let attributeAsLabel = updatedAttributes.first(where: { $0.code == family.attributeAsLabel}),
              let value = self.getValue(values: updatedValues, attribute: attributeAsLabel, context: updatedCatalogContext)?.value as? TextProductValue else {
          return self.identifier;
        }
        
        return value.stringValue();
      }
      .eraseToAnyPublisher()
      .assign(to: \.label, on: self)
      .store(in: &cancellableSet)
  }
  
  func updateImagesOnFamilyChange()
  {
    self.$family
      .receive(on: RunLoop.main)
      .removeDuplicates()
      .combineLatest(self.$values, self.$attributes) { (family, values, attributes) -> [String] in
        guard let family = family,
              let attributeAsMainImage = attributes.first(where: { $0.code == family.attributeAsMainImage}),
              let value = self.getValue(values: values, attribute: attributeAsMainImage, context: catalogContext)?.value as? ImageProductValue else {
          return []
        }
        
        return [value.href]
      }
      .eraseToAnyPublisher()
      .assign(to: \.images, on: self)
      .store(in: &cancellableSet)
  }
  
  func updateCategoryOnCodesChange() {
    self.$categoryCodes
      .receive(on: RunLoop.main)
      .removeDuplicates()
      .flatMap { categoryCodes in
        return AkeneoApi.sharedInstance.category.getByCodes(codes: categoryCodes)
      }
      .eraseToAnyPublisher()
      .assign(to: \.categories, on: self)
      .store(in: &cancellableSet)
      
  }
  
  func updateCategoryLabelsOnCategoryChange()
  {
    self.$categories
      .receive(on: RunLoop.main)
      .removeDuplicates()
      .map { categories in
        return categories.map { (category) -> String in
          guard let label = category.labels[self.context.locale] else {
            return category.code
          }
          
          return label
        }
      }
      .eraseToAnyPublisher()
      .assign(to: \.categoryLabels, on: self)
      .store(in: &cancellableSet)
  }
  
  func getValue(values: [IdentifiableProductValue], attribute: Attribute, context: CatalogContext) -> IdentifiableProductValue? {
    return values.first { productValue -> Bool in
      return productValue.match(attribute: attribute, context: context)
    }
  }
  
  var cancellableSet = Set<AnyCancellable>()
  func cancel() {
    self.cancellableSet.forEach { (cancellable) in
      cancellable.cancel()
    }
  }
}
