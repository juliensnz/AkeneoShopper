//
//  ProductHeader.swift
//  AkeneoShopper
//
//  Created by Julien Sanchez on 20/01/2021.
//

import SwiftUI

struct ProductHeader: View {
  var product: ProductListItem
  @State var currentPicture: Int = 0;
  @State var isDisplayed = false;
  let isExpanded: Bool
  
  #if os(iOS)
  let isDraggableDevice = true
  #else
  let isDraggableDevice = false
  #endif
  
  var body: some View {
    ZStack {
      ImageSliderView(itemCount: picturesData.count, isReadOnly: !isExpanded || !isDisplayed, currentIndex: self.$currentPicture) {
        ForEach(0..<picturesData.count) { index in
          #if os(iOS)
          Image(uiImage: picturesData[index])
            .resizable()
            .scaledToFill()
          #else
          Image(nsImage: picturesData[index])
            .resizable()
            .scaledToFill()
          #endif
        }
      }
      VStack {
        Spacer()
        if isExpanded {
          HStack(alignment: .bottom) {
            ImageSliderIndicator(currentPage: currentPicture, pageCount: picturesData.count)
            Spacer()
            
            if (!isDraggableDevice) {
              CircularButton(icon: "arrow.left") {
                if currentPicture > 0 {
                  currentPicture -= 1
                }
              }
              
              CircularButton(icon: "arrow.right") {
                if currentPicture < picturesData.count - 1 {
                  currentPicture += 1
                }
              }
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
              .frame(maxWidth: .infinity, alignment: .bottomLeading)
            
            Text(product.family)
              .padding(.vertical, 2)
              .padding(.horizontal, 8)
              .background(familyColorsData[0])
              .cornerRadius(8)
          }
          
          Text(product.categories.joined(separator: ", "))
        }
        .padding(10)
        .background(VisualEffectBlur())
        .frame(maxWidth: .infinity, alignment: .bottomLeading)
      }
      .animation(.none)
    }
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
