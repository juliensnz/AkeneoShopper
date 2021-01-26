//
//  AsyncImage.swift
//  AkeneoShopper
//
//  Created by Julien Sanchez on 23/01/2021.
//

import SwiftUI
#if os(iOS)
import UIKit
#endif

struct AsyncImage: View {
  let url: String
  @State var image: UIImage = UIImage(imageLiteralResourceName: "placeholder");
  
  var body: some View {
    content
      .onAppear(perform: {
        _ = ImageLoader.shared.loadImage(from: self.url)
          .replaceNil(with: UIImage(imageLiteralResourceName: "placeholder"))
          .eraseToAnyPublisher()
          .assign(to: \.image, on: self)
      })
  }
  
  private var content: some View {
    return Image(uiImage: self.image)
      .resizable()
  }
}
