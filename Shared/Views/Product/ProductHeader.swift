//
//  ProductHeader.swift
//  AkeneoShopper
//
//  Created by Julien Sanchez on 20/01/2021.
//

import SwiftUI

struct ProductHeader: View {
  @ObservedObject var product: Product;
  @State var currentPicture: Int = 0;
  @State var isDisplayed = false;
  let isExpanded: Bool
  
  #if os(iOS)
  let isDraggableDevice = true
  #else
  let isDraggableDevice = false
  #endif
  
  var body: some View {
    let pictureCount = self.product.images.count;
    ZStack {
      ImageSliderView(itemCount: pictureCount, isReadOnly: !isExpanded || !isDisplayed, currentIndex: self.$currentPicture) {
        if (self.product.images.isEmpty) {
          AsyncImage(url: nil)
            .scaledToFill()
        } else {
          ForEach(self.product.images, id: \.self) { image in
            AsyncImage(url: image)
              .scaledToFill()
          }
        }
      }
      VStack {
        Spacer()
        if isExpanded && pictureCount > 0 {
          HStack(alignment: .bottom) {
            ImageSliderIndicator(currentPage: currentPicture, pageCount: pictureCount)
            Spacer()
            
            if (!isDraggableDevice) {
              let isLastPicture = currentPicture == pictureCount - 1;
              let isFirstPicture = currentPicture == 0;
              
              CircularButton(icon: "arrow.left") {
                currentPicture -= 1
              }
              .opacity(isFirstPicture ? 0.5 : 1)
              .disabled(isFirstPicture)
              
              CircularButton(icon: "arrow.right") {
                currentPicture += 1
              }
              .opacity(isLastPicture ? 0.5 : 1)
              .disabled(isLastPicture)
            }
            
            CircularButton(icon: "arrow.up.left.and.arrow.down.right") {}
          }
          .padding(.horizontal, 8)
          // https://stackoverflow.com/questions/59682446/how-to-trigger-action-after-x-seconds-in-swiftui
          .onAppear(perform: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
              self.isDisplayed = true
            }
          })
          .onDisappear(perform: {
            self.isDisplayed = false
          })
          .opacity(self.isDisplayed ? 1 : 0)
          .animation(.easeInOut)
        }
        VStack(alignment: .leading, spacing: 0) {
          HStack {
            Text(product.label)
              .font(.title)
              .fontWeight(.light)
              .lineLimit(1)
              .frame(maxWidth: .infinity, alignment: .bottomLeading)
              .truncationMode(.tail)
            
            Text(product.familyLabel)
              .padding(.vertical, 2)
              .padding(.horizontal, 8)
              .background(familyColorsData[0])
              .cornerRadius(8)
          }
          
          Text(product.categoryLabels.joined(separator: ", "))
        }
        .padding(10)
        .background(VisualEffectBlur())
        .frame(maxWidth: .infinity, alignment: .bottomLeading)
      }
      .animation(.none)
    }
    .background(Color.white)
    .clipShape(RoundedRectangle(cornerRadius: self.isExpanded ? 0 : 20, style: .continuous))
  }
}

struct ProductHeader_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      ProductHeader(product: productsData[0], isExpanded: false)
        .previewLayout(.fixed(width: 400, height: 300))
      ProductHeader(product: productsData[0], isExpanded: true)
        .previewLayout(.fixed(width: 400, height: 300))
    }
  }
}
