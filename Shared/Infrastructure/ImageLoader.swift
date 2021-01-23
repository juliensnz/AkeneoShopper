//
//  ImageLoader.swift
//  AkeneoShopper
//
//  Created by Julien Sanchez on 23/01/2021.
//

import SwiftUI
import Combine
import Foundation

class ImageLoader: ObservableObject {
  @Published var image: UIImage?
  private let url: String?
  private var cancellable: AnyCancellable?
  
  init(url: String?) {
    self.url = url
  }
  
  deinit {
    cancel()
  }
  
  func load() {
//    guard let url = self.url else {return}
//    guard let safeUrl = URL(string: url) else {return}
//    AkeneoApi.sharedInstance.loadImage(url: safeUrl, onSuccess: { (publisher) in
//      self.cancellable = publisher
//        .map { UIImage(data: $0.data) }
//        .replaceError(with: nil)
//        .receive(on: DispatchQueue.main)
//        .sink { [weak self] in self?.image = $0 }
//    }, onFailure: { (error) in
//      print(error)
//    })
  }
  
  func cancel() {
    cancellable?.cancel()
  }
}
