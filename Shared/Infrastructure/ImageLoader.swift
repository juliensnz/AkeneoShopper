//
//  ImageLoader.swift
//  AkeneoShopper
//
//  Created by Julien Sanchez on 23/01/2021.
//

import SwiftUI
import Combine
import Foundation

final class ImageLoader {
  private let cache: ImageCacheType
  public static let shared = ImageLoader()
  private lazy var backgroundQueue: OperationQueue = {
    let queue = OperationQueue()
    queue.maxConcurrentOperationCount = 5
    return queue
  }()
  
  public init(cache: ImageCacheType = ImageCache()) {
    self.cache = cache
  }
  
//  func loadImage(from url: String) -> AnyPublisher<UIImage, Never> {
//    if let image = cache[url] {
//      return Just(image).eraseToAnyPublisher()
//    }
//
//    return AkeneoApi.sharedInstance.image.get(url: url)
//      .eraseToAnyPublisher();
//
//    return AkeneoApi.sharedInstance.image.get(url: url)
//      .catch { error in return Just(nil) }
//      .handleEvents(receiveOutput: {[unowned self] image in
//        guard let image = image else { return }
//        self.cache[url] = image
//      })
//      .subscribe(on: backgroundQueue)
//      .receive(on: RunLoop.main)
//      .eraseToAnyPublisher()
//  }
}
