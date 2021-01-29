//
//  AkeneoCategoryApi.swift
//  AkeneoShopper (iOS)
//
//  Created by Julien Sanchez on 15/01/2021.
//

import SwiftUI
import Combine

class AkeneoCategoryApi: Cancellable {
  @Published var categoryCodesToLoad: [String] = [];
  @Published var categories: [Category] = []
  
  var cancellableSet = Set<AnyCancellable>()
  func cancel() {
    self.cancellableSet.forEach { (cancellable) in
      cancellable.cancel()
    }
  }
  
  init() {
    self.$categoryCodesToLoad
      .receive(on: RunLoop.main)
      .debounce(for: 0.5, scheduler: RunLoop.main)
      .map({ (categoryCodes) -> [String] in
        return Array(Set(categoryCodes)).filter { (categoryCode) -> Bool in
          return !self.categories.map({ (category) -> String in
            category.code
          }).contains(categoryCode)
        }
      })
      .removeDuplicates()
      .filter({ (categoryCodes) -> Bool in
        return categoryCodes.count > 0
      })
      .flatMap { categoryCodes in
        return self.getCategoriesByCode(categoryCodes: categoryCodes)
      }
      .replaceError(with: [])
      .map({ (newCategories: [Category]) -> [Category] in
        return Array(Set(newCategories + self.categories))
      })
      .eraseToAnyPublisher()
      .assign(to: \.categories, on: self)
      .store(in: &cancellableSet)
  }
  
  private func getCategoriesByCode(categoryCodes: [String]) -> AnyPublisher<[Category], ApiError> {
    let joinedCategoryCodes = categoryCodes.map({ #""\#($0)""# }).joined(separator: ",")
    let search = #"{"code":[{"operator":"IN","value":[\#(joinedCategoryCodes)]}]}"#
    print("search")
    print(categoryCodes)
    
    let url = "\(AkeneoApi.sharedInstance.access.baseUrl)/api/rest/v1/categories";
    guard var urlComponents = URLComponents(string: url) else {
      return Fail<[Category], ApiError>(error: ApiError.badUrl(message: "Invalid URL: \(url)"))
        .eraseToAnyPublisher()
    }
    
    urlComponents.queryItems = [
      URLQueryItem(name: "search", value: search),
      URLQueryItem(name: "limit", value: "100")
    ];
    
    guard let validUrl = urlComponents.url else {
      return Fail<[Category], ApiError>(error: ApiError.badUrl(message: "Invalid URL: \(url)"))
        .eraseToAnyPublisher()
    }
    
    return AkeneoApi.sharedInstance.get(url: validUrl)
      .map { (data) -> [Category] in
        return CategoryDenormalizer.denormalizeAll(data: data)
      }
      .eraseToAnyPublisher()
  }
  
  func getByCodes(codes: [String]) -> AnyPublisher<[Category], Never> {
    self.categoryCodesToLoad = Array(Set(codes + self.categoryCodesToLoad))
    
    return self.$categories.map({ (categories) -> [Category] in
      let filteredCategories = categories.filter { (category) -> Bool in
        return codes.contains(category.code)
      }
            
      return filteredCategories
    })
    .eraseToAnyPublisher()
  }
}
