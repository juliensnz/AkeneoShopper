//
//  AkeneoFamilyApi.swift
//  AkeneoShopper (iOS)
//
//  Created by Julien Sanchez on 15/01/2021.
//

import SwiftUI
import Combine

class AkeneoFamilyApi: Cancellable {
  @Published var familyCodesToLoad: [String] = [];
  @Published var families: [Family] = []
  
  var cancellableSet = Set<AnyCancellable>()
  func cancel() {
    self.cancellableSet.forEach { (cancellable) in
      cancellable.cancel()
    }
  }
  
  init() {
    self.$familyCodesToLoad
      .receive(on: RunLoop.main)
      .debounce(for: 0.5, scheduler: RunLoop.main)
      .map({ (familyCodes) -> [String] in
        return Array(Set(familyCodes)).filter { (familyCode) -> Bool in
          return !self.families.map({ (family) -> String in
            family.code
          }).contains(familyCode)
        }
      })
      .removeDuplicates()
      .filter({ (familyCodes) -> Bool in
        return familyCodes.count > 0
      })
      .flatMap { familyCodes in
        return self.getFamiliesByCode(familyCodes: familyCodes)
      }
      .catch({ (error) -> Just<[Family]> in
        print("Error occured during family fetching: \(error.localizedDescription)")
        return Just([])
      })
      .map({ (newFamilies: [Family]) -> [Family] in
        return Array(Set(newFamilies + self.families))
      })
      .eraseToAnyPublisher()
      .assign(to: \.families, on: self)
      .store(in: &cancellableSet)
  }
  
  private func getFamiliesByCode(familyCodes: [String]) -> AnyPublisher<[Family], ApiError> {
    let joinedFamilyCodes = familyCodes.map({ #""\#($0)""# }).joined(separator: ",")
    let search = #"{"code":[{"operator":"IN","value":[\#(joinedFamilyCodes)]}]}"#
    print("search")
    print(familyCodes)
    
    let url = "\(AkeneoApi.sharedInstance.access.baseUrl)/api/rest/v1/families";
    guard var urlComponents = URLComponents(string: url) else {
      return Fail<[Family], ApiError>(error: ApiError.badUrl(message: "Invalid URL: \(url)"))
        .eraseToAnyPublisher()
    }
    
    urlComponents.queryItems = [
      URLQueryItem(name: "search", value: search),
      URLQueryItem(name: "limit", value: "100")
    ];
    
    guard let validUrl = urlComponents.url else {
      return Fail<[Family], ApiError>(error: ApiError.badUrl(message: "Invalid URL: \(url)"))
        .eraseToAnyPublisher()
    }
    
    return AkeneoApi.sharedInstance.get(url: validUrl)
      .map { (data) -> [Family] in
        return FamilyDenormalizer.denormalizeAll(data: data)
      }
      .eraseToAnyPublisher()
  }
  
  func get(code: String) -> AnyPublisher<Family?, Never> {
    self.familyCodesToLoad.append(code);
    
    return self.$families.map({ (families) -> Family? in
      guard let index = families.firstIndex(where: { (family) -> Bool in
        return family.code == code
      }) else {
        return nil
      }
      
      return families[index]
    })
    .eraseToAnyPublisher()
  }
}
