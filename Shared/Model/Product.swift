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
  
  let enabled: Bool;
  @Published var images: [String] = []
  
  @Published var family: Family? = nil
  @Published var categories: [Category] = []
  
  var values: [String: Any] = [:]
  
  init(identifier: String, enabled: Bool, familyCode: String, categoryCodes: [String], rawValues: [String: JSON], context: CatalogContext)
  {
    self.identifier = identifier;
    self.enabled = enabled;
    self.familyCode = familyCode;
    self.rawValues = rawValues;
    self.categoryCodes = categoryCodes;
    self.context = context;
    
    self.familyLabel = familyCode;
    self.categoryLabels = categoryCodes;
    self.label = identifier
    
    self.updateFamilyOnCodeChange()
    self.updateFamilyLabelOnFamilyChange()
    self.updateLabelOnFamilyChange()
    
    self.updateImagesOnFamilyChange()
    
    self.updateCategoryOnCodesChange()
    self.updateCategoryLabelsOnCategoryChange()
  }
  
  func updateFamilyOnCodeChange()
  {
    self.$familyCode
      .receive(on: RunLoop.main)
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
  
  func updateLabelOnFamilyChange()
  {
    self.$family
      .receive(on: RunLoop.main)
      .combineLatest(self.$rawValues) { updatedFamily, updatedValues in
        guard let family = updatedFamily else {
          return self.familyCode
        }
        
        let attributeAsLabelCode = family.attributeAsLabel;
        
        guard let valuesAsLabel = updatedValues[attributeAsLabelCode]?.array else {
          return self.identifier
        }
        
        guard let labelValueIndex = valuesAsLabel.firstIndex(where: { value in
          return (
            nil == value["locale"].string || value["locale"].string == self.context.locale &&
              nil == value["scope"].string || value["scope"].string == self.context.channel
          )
        }) else {
          return self.identifier
        }
        
        guard let label = valuesAsLabel[labelValueIndex]["data"].string else {
          return self.identifier
        }
        
        return label
      }
      .eraseToAnyPublisher()
      .assign(to: \.label, on: self)
      .store(in: &cancellableSet)
  }
  
  func updateImagesOnFamilyChange()
  {
    self.$family
      .receive(on: RunLoop.main)
      .combineLatest(self.$rawValues) { (updatedFamily, updatedValues) -> [String] in
        guard let family = updatedFamily else {
          return []
        }
        
        let attributeAsMainImageCode = family.attributeAsMainImage;
        
        guard let valuesAsMainImage = updatedValues[attributeAsMainImageCode]?.array else {
          return []
        }
        
        guard let mainImageValueIndex = valuesAsMainImage.firstIndex(where: { value in
          return (
            nil == value["locale"].string || value["locale"].string == self.context.locale &&
              nil == value["scope"].string || value["scope"].string == self.context.channel
          )
        }) else {
          return []
        }
        
        guard let image = valuesAsMainImage[mainImageValueIndex]["links"]["download"]["href"].string else {
          return []
        }
        
        return [image]
      }
      .eraseToAnyPublisher()
      .assign(to: \.images, on: self)
      .store(in: &cancellableSet)
  }
  
  func updateCategoryOnCodesChange() {
    self.$categoryCodes
      .receive(on: RunLoop.main)
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
  
  var cancellableSet = Set<AnyCancellable>()
  func cancel() {
    self.cancellableSet.forEach { (cancellable) in
      cancellable.cancel()
    }
  }
}
