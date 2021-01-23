//
//  AsyncImage.swift
//  AkeneoShopper
//
//  Created by Julien Sanchez on 23/01/2021.
//

import SwiftUI

struct AsyncImage<Placeholder: View>: View {
  @StateObject private var loader: ImageLoader
  private let placeholder: Placeholder
  
  init(url: String?, @ViewBuilder placeholder: () -> Placeholder) {
    self.placeholder = placeholder()
    
    _loader = StateObject(wrappedValue: ImageLoader(url: url))
  }
  
  var body: some View {
    content
      .onAppear(perform: loader.load)
  }
  
  private var content: some View {
    Group {
      if loader.image != nil {
        Image(uiImage: loader.image!)
          .resizable()
      } else {
        placeholder
      }
    }
  }
}
