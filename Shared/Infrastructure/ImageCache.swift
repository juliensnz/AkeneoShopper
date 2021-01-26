//
//  ImageCache.swift
//  AkeneoShopper
//
//  Created by Julien Sanchez on 25/01/2021.
//

import Foundation
import SwiftUI

protocol ImageCacheType: class {
  // Returns the image associated with a given url
  func image(for url: String) -> UIImage?
  // Inserts the image of the specified url in the cache
  func insertImage(_ image: UIImage?, for url: String)
  // Removes the image of the specified url in the cache
  func removeImage(for url: String)
  // Removes all images from the cache
  func removeAllImages()
  // Accesses the value associated with the given key for reading and writing
  subscript(_ url: String) -> UIImage? { get set }
}

extension UIImage {
  func decodedImage() -> (UIImage, Int) {
    guard let cgImage = cgImage else { return (self, 0) }
    let size = CGSize(width: cgImage.width, height: cgImage.height)
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let context = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: cgImage.bytesPerRow, space: colorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
    context?.draw(cgImage, in: CGRect(origin: .zero, size: size))
    guard let decodedImage = context?.makeImage() else { return (self, 0) }
    
    #if os(iOS)    
    return (UIImage(cgImage: decodedImage), 100)
    #else
    let image = UIImage(cgImage: decodedImage, size: .zero)
    let tiffSize = image.tiffRepresentation?.count ?? 1000 * 100;
    
    return (UIImage(cgImage: decodedImage, size: .zero), tiffSize/1000)
    #endif
  }
}

//https://medium.com/flawless-app-stories/reusable-image-cache-in-swift-9b90eb338e8d
final class ImageCache: ImageCacheType {
  // 1st level cache, that contains encoded images
  private lazy var imageCache: NSCache<AnyObject, AnyObject> = {
    let cache = NSCache<AnyObject, AnyObject>()
    cache.countLimit = config.countLimit
    return cache
  }()
  // 2nd level cache, that contains decoded images
  private lazy var decodedImageCache: NSCache<AnyObject, AnyObject> = {
    let cache = NSCache<AnyObject, AnyObject>()
    cache.countLimit = config.countLimit
    return cache
  }()
  private let lock = NSLock()
  private let config: Config
  
  struct Config {
    let countLimit: Int
    let memoryLimit: Int
    
    static let defaultConfig = Config(countLimit: 100, memoryLimit: 1024 * 1024 * 100) // 100 MB
  }
  
  init(config: Config = Config.defaultConfig) {
    self.config = config
  }
  
  func insertImage(_ image: UIImage?, for url: String) {
    guard let image = image else { return removeImage(for: url) }
    let (decodedImage, size) = image.decodedImage()
    
    lock.lock(); defer { lock.unlock() }
    imageCache.setObject(decodedImage, forKey: url as AnyObject)
    
    
    
    decodedImageCache.setObject(image as AnyObject, forKey: url as AnyObject, cost: size)
  }
  
  func removeImage(for url: String) {
    lock.lock(); defer { lock.unlock() }
    imageCache.removeObject(forKey: url as AnyObject)
    decodedImageCache.removeObject(forKey: url as AnyObject)
  }
  
  func image(for url: String) -> UIImage? {
    lock.lock(); defer { lock.unlock() }
    // the best case scenario -> there is a decoded image
    if let decodedImage = decodedImageCache.object(forKey: url as AnyObject) as? UIImage {
      return decodedImage
    }
    // search for image data
    if let image = imageCache.object(forKey: url as AnyObject) as? UIImage {
      let (decodedImage, size) = image.decodedImage()
      decodedImageCache.setObject(image as AnyObject, forKey: url as AnyObject, cost: size)
      
      return decodedImage
    }
    return nil
  }
  
  func removeAllImages() {
    lock.lock(); defer { lock.unlock() }
    
    imageCache.removeAllObjects()
    decodedImageCache.removeAllObjects()
  }
  
  subscript(_ key: String) -> UIImage? {
    get {
      return image(for: key)
    }
    set {
      return insertImage(newValue, for: key)
    }
  }
}
