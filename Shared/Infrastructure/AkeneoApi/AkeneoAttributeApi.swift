//
//  AkeneoAttributeApi.swift
//  AkeneoShopper (iOS)
//
//  Created by Julien Sanchez on 27/01/2021.
//

import SwiftUI
import Combine

class AkeneoAttributeApi: Cancellable {
  @Published var attributeCodesToLoad: [String] = [];
  @Published var attributes: [Attribute] = []
  
  var cancellableSet = Set<AnyCancellable>()
  func cancel() {
    self.cancellableSet.forEach { (cancellable) in
      cancellable.cancel()
    }
  }
  
  init() {
    self.$attributeCodesToLoad
      .receive(on: RunLoop.main)
      .debounce(for: 0.5, scheduler: RunLoop.main)
      .map({ (attributeCodes) -> [String] in
        return Array(Set(attributeCodes)).filter { (attributeCode) -> Bool in
          return !self.attributes.map({ (attribute) -> String in
            attribute.code
          }).contains(attributeCode)
        }
      })
      .removeDuplicates()
      .filter({ (attributeCodes) -> Bool in
        return attributeCodes.count > 0
      })
      .flatMap { attributeCodes in
        return self.getAttributesByCode(attributeCodes: attributeCodes)
      }
      .replaceError(with: [])
      .map({ (newAttributes: [Attribute]) -> [Attribute] in
        return Array(Set(newAttributes + self.attributes))
      })
      .eraseToAnyPublisher()
      .assign(to: \.attributes, on: self)
      .store(in: &cancellableSet)
  }
  
  private func getAttributesByCode(attributeCodes: [String]) -> AnyPublisher<[Attribute], ApiError> {
    let joinedAttributeCodes = attributeCodes.map({ #""\#($0)""# }).joined(separator: ",")
    let search = #"{"code":[{"operator":"IN","value":[\#(joinedAttributeCodes)]}]}"#
    print("search")
    print(attributeCodes)
    
    let url = "\(AkeneoApi.sharedInstance.access.baseUrl)/api/rest/v1/attributes";
    guard var urlComponents = URLComponents(string: url) else {
      return Fail<[Attribute], ApiError>(error: ApiError.badUrl(message: "Invalid URL: \(url)"))
        .eraseToAnyPublisher()
    }
    
    urlComponents.queryItems = [
      URLQueryItem(name: "search", value: search),
      URLQueryItem(name: "limit", value: "100")
    ];
    
    guard let validUrl = urlComponents.url else {
      return Fail<[Attribute], ApiError>(error: ApiError.badUrl(message: "Invalid URL: \(url)"))
        .eraseToAnyPublisher()
    }
    
    return AkeneoApi.sharedInstance.get(url: validUrl)
      .map { (data) -> [Attribute] in
        return AttributeDenormalizer.denormalizeAll(data: data)
      }
      .eraseToAnyPublisher()
  }
  
  func getByCodes(codes: [String]) -> AnyPublisher<[Attribute], Never> {
    self.attributeCodesToLoad = Array(Set(codes + self.attributeCodesToLoad))
    
    return self.$attributes.map({ (attributes) -> [Attribute] in
      let filteredAttributes = attributes.filter { (attribute) -> Bool in
        return codes.contains(attribute.code)
      }
            
      return filteredAttributes
    })
    .eraseToAnyPublisher()
  }
}
