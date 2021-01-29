//
//  AsyncImage.swift
//  AkeneoShopper
//
//  Created by Julien Sanchez on 23/01/2021.
//

import SwiftUI
import Combine
#if os(iOS)
import UIKit
#endif

struct AsyncImage: View {
  let url: String?
  @State var image: UIImage = UIImage(imageLiteralResourceName: "placeholder");
  
  var body: some View {
    content
      .onAppear(perform: {
        guard let nonNilUrl = self.url else {
          return
        }
        
        _ = AkeneoApi.sharedInstance.image.get(url: nonNilUrl)
          .map({ image in
            print("image loaded")
            print(image)
            return image
          })
          .catch {error in return Just(nil)}
          .replaceNil(with: UIImage(imageLiteralResourceName: "placeholder"))
          .eraseToAnyPublisher()
          .assign(to: \.image, on: self)
        //        _ = Just(self.url)
        //          .flatMap { updatedUrl -> AnyPublisher<UIImage?, Never> in
        //            guard let nonNilUrl = updatedUrl else {
        //              return Just(nil)
        //                .eraseToAnyPublisher()
        //            }
        //            print(nonNilUrl);
        //
        //            return AkeneoApi.sharedInstance.image.get(url: nonNilUrl)
        //              .catch {error in return Just(nil)}
        //              .eraseToAnyPublisher()
        //          }
        //          .replaceNil(with: UIImage(imageLiteralResourceName: "placeholder"))
        //          .eraseToAnyPublisher()
        //          .assign(to: \.image, on: self)
      })
  }
  
  private var content: some View {
    #if os(iOS)
    return Image(uiImage: self.image)
      .resizable()
    #else
    return Image(nsImage: self.image)
      .resizable()
    #endif
  }
}
