//
//  ImageSliderView.swift
//  AkeneoShopper (iOS)
//
//  Created by Julien Sanchez on 16/01/2021.
//

import SwiftUI

struct ImageSliderItem: Identifiable {
  let id = UUID();
  #if os(iOS)
  let image: UIImage;
  #else
  let image: NSImage;
  #endif
}

/**
  * https://stackoverflow.com/questions/58896661/swiftui-create-image-slider-with-dots-as-indicators
 */
struct ImageSliderView<Content>: View where Content: View {
  var externalCurrentIndex: Binding<Int>?;
  @State var internaleCurrentIndex: Int = 0;
  
  #if os(iOS)
  let isDraggableDevice = true
  #else
  let isDraggableDevice = false
  #endif
  
  var currentIndex: Int {
    get {
      return externalCurrentIndex?.wrappedValue ?? internaleCurrentIndex
    }
  }
  
  let itemCount: Int;
  let isReadOnly: Bool
  let content: () -> Content;
  
  @State var offset = CGFloat.zero;
  @State var dragging = false;
  
  init(itemCount: Int, isReadOnly: Bool = false, currentIndex: Binding<Int>? = nil, @ViewBuilder content: @escaping () -> Content) {
    if let currentIndex = currentIndex {
      self.externalCurrentIndex = currentIndex
    }
    self.itemCount = itemCount
    self.isReadOnly = isReadOnly
    self.content = content
  }
  
  var body: some View {
    ZStack {
      GeometryReader { geometry in
        ZStack {
          ScrollView (.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
              self.content()
                .frame(width: geometry.size.width, height: geometry.size.height)
                .clipped()
            }
          }
          .content.offset(x: self.offset(in: geometry), y: 0)
          .frame(width: geometry.size.width, height: geometry.size.height, alignment: .leading)
          .gesture(DragGesture().onChanged({ (value) in
            if isReadOnly || !isDraggableDevice {
              return
            }
            self.dragging = true
            self.offset = -CGFloat(self.currentIndex) * geometry.size.width + value.translation.width
          }).onEnded({ (value) in
            if isReadOnly || !isDraggableDevice {
              return
            }
            let predictedEndOffset = -CGFloat(self.currentIndex) * geometry.size.width + value.predictedEndTranslation.width
            let predictedIndex = Int(round(predictedEndOffset / -geometry.size.width))
            
            if let externalCurrentIndex = externalCurrentIndex {
              externalCurrentIndex.wrappedValue = self.clampedIndex(from: predictedIndex)
            } else {
              self.internaleCurrentIndex = self.clampedIndex(from: predictedIndex)
            }
            
            withAnimation(.easeOut) {
                self.dragging = false
            }
          }))
          .animation(isReadOnly ? .none : .spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0))
        }
      }
      if (itemCount > 0 && !isReadOnly) {
        ImageSliderIndicator(currentPage: self.currentIndex, pageCount: self.itemCount)
          .padding(10)
          .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
      }
    }.clipped()
  }
  
  func offset(in geometry: GeometryProxy) -> CGFloat {
    if self.dragging {
      return max(min(self.offset, 0), -CGFloat(self.itemCount - 1) * geometry.size.width)
    } else {
      return -CGFloat(self.currentIndex) * geometry.size.width
    }
  }
  
  func clampedIndex(from predictedIndex: Int) -> Int {
      let newIndex = min(max(predictedIndex, self.currentIndex - 1), self.currentIndex + 1)
      guard newIndex >= 0 else { return 0 }
      guard newIndex < itemCount - 1 else { return itemCount - 1 }
    
      return newIndex
  }
}

struct ImageSliderIndicator: View {
  let currentPage: Int;
  let pageCount: Int;
  
  var body: some View {
    HStack(spacing: 8) {
      ForEach(0..<pageCount) { index in
        #if os(iOS)
        Rectangle()
          .foregroundColor(Color.white.opacity(currentPage == index ? 1 : 0))
          .background(BlurView(style: .systemUltraThinMaterial))
          .clipShape(Circle())
          .frame(width: 8, height: 8)
          .animation(.easeInOut)
        #else
        Rectangle()
          .foregroundColor(Color.white.opacity(currentPage == index ? 1 : 0))
          .background(Color.white.opacity(0.4))
          .clipShape(Circle())
          .frame(width: 8, height: 8)
          .animation(.easeInOut)
        #endif
      }
    }
  }
}

struct ImageSliderView_Previews: PreviewProvider {
  @State var index = 0;
  static var previews: some View {
    Group {
      ImageSliderView(itemCount: 3) {
        #if os(iOS)
        Image(uiImage: #imageLiteral(resourceName: "FREKVENS_table"))
          .resizable()
          .scaledToFill()
        Image(uiImage: #imageLiteral(resourceName: "FREKVENS_sofa"))
          .resizable()
          .scaledToFill()
        Image(uiImage: #imageLiteral(resourceName: "FREKVENS_light"))
          .resizable()
          .scaledToFill()
        #else
        Image(nsImage: #imageLiteral(resourceName: "FREKVENS_table"))
          .resizable()
          .scaledToFill()
        Image(nsImage: #imageLiteral(resourceName: "FREKVENS_sofa"))
          .resizable()
          .scaledToFill()
        Image(nsImage: #imageLiteral(resourceName: "FREKVENS_light"))
          .resizable()
          .scaledToFill()
        #endif
      }
      .previewLayout(.fixed(width: 300.0, height: 200.0))
      ImageSliderView(itemCount: 3, isReadOnly: true) {
        #if os(iOS)
        Image(uiImage: #imageLiteral(resourceName: "FREKVENS_table"))
          .resizable()
          .scaledToFill()
        Image(uiImage: #imageLiteral(resourceName: "FREKVENS_sofa"))
          .resizable()
          .scaledToFill()
        Image(uiImage: #imageLiteral(resourceName: "FREKVENS_light"))
          .resizable()
          .scaledToFill()
        #else
        Image(nsImage: #imageLiteral(resourceName: "FREKVENS_table"))
          .resizable()
          .scaledToFill()
        Image(nsImage: #imageLiteral(resourceName: "FREKVENS_sofa"))
          .resizable()
          .scaledToFill()
        Image(nsImage: #imageLiteral(resourceName: "FREKVENS_light"))
          .resizable()
          .scaledToFill()
        #endif
      }
      .previewLayout(.fixed(width: 300.0, height: 200.0))
    }
  }
}
