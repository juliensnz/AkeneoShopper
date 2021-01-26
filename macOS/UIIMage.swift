//
//  UIIMage.swift
//  AkeneoShopper (macOS)
//
//  Created by Julien Sanchez on 25/01/2021.
//

import Cocoa

//https://www.swiftbysundell.com/tips/making-uiimage-macos-compatible/
// Step 1: Typealias UIImage to NSImage
typealias UIImage = NSImage

// Step 2: You might want to add these APIs that UIImage has but NSImage doesn't.
extension NSImage {
  var cgImage: CGImage? {
    var proposedRect = CGRect(origin: .zero, size: size)
    
    return cgImage(forProposedRect: &proposedRect,
                   context: nil,
                   hints: nil)
  }
  
  convenience init?(named name: String) {
    self.init(named: Name(name))
  }
}
