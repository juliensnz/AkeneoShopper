//
//  AkeneoAttributeApi.swift
//  AkeneoShopper (iOS)
//
//  Created by Julien Sanchez on 27/01/2021.
//

import SwiftUI
import Combine


//@AppStorage("baseUrl") var baseUrl = "http://ped.test:8080"
//@AppStorage("clientID") var clientID = "1_16d23okvhfb44ccgo8s4wgoo8swocokcgsk0c0o4c084k00ks4"
//@AppStorage("secret") var secret = "2crnhds1wx5wocwsg4sw0cgwo0w0sckwcokg8go4sck8c44cso"
//@AppStorage("user") var user = "magento_0000"
//@AppStorage("password") var password = "2dpuj5tx4w4d"

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
      .catch({ (error) -> Just<[Attribute]> in
        print("Error occured during attribute fetching: \(error.localizedDescription)")
        return Just([])
      })
      .map({ (newAttributes: [Attribute]) -> [Attribute] in
        return Array(Set(newAttributes + self.attributes))
      })
      .eraseToAnyPublisher()
      .assign(to: \.attributes, on: self)
      .store(in: &cancellableSet)
  }
  
  public func fetchAllAttributes() {
    let url = "\(AkeneoApi.sharedInstance.access.baseUrl)/api/rest/v1/attributes";
    guard var urlComponents = URLComponents(string: url) else {
      return
    }
    
    urlComponents.queryItems = [
      URLQueryItem(name: "limit", value: "100")
    ];
    
    guard let validUrl = urlComponents.url else {
      return
    }
    
    self.getAttributesFromPage(url: validUrl)
      .replaceError(with: self.attributes)
      .eraseToAnyPublisher()
      .assign(to: \.attributes, on: self)
      .store(in: &cancellableSet)
  }
  
  private func getAttributesFromPage(url: URL) -> AnyPublisher<[Attribute], ApiError> {
    return AkeneoApi.sharedInstance.get(url: url)
      .flatMap { (data) -> AnyPublisher<[Attribute], ApiError> in
        let currentPageAttributes = AttributeDenormalizer.denormalizeAll(data: data);
        
        // If there is a next page
        if let nextPage = data["_links"]["next"]["href"].string {
          guard let nextPageUrl = URL(string: nextPage) else {
            return Fail<[Attribute], ApiError>(error: ApiError.badUrl(message: "Invalid URL: \(nextPage)"))
              .eraseToAnyPublisher()
          }
          
          return self.getAttributesFromPage(url: nextPageUrl)
            .map { (nextPageAttributes: [Attribute]) -> [Attribute] in
              return currentPageAttributes + nextPageAttributes
            }
            .eraseToAnyPublisher()
        }
        
        // We are on the last page
        return Just(currentPageAttributes)
          .setFailureType(to: ApiError.self)
          .eraseToAnyPublisher()
      }
      .eraseToAnyPublisher()
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
  
  func getIdentifier() -> AnyPublisher<Attribute, Never> {
    return self.$attributes
      .drop(while: { (attributes) -> Bool in
        return attributes.first(where: { $0.type == "pim_catalog_identifier" }) == nil
      })
      .map({ (attributes) -> Attribute in
        return attributes.first { (attribute) -> Bool in
          return attribute.type == "pim_catalog_identifier"
        }!
      })
      .eraseToAnyPublisher()
  }
}
