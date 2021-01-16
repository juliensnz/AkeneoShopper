//
//  ImageSliderView.swift
//  AkeneoShopper (iOS)
//
//  Created by Julien Sanchez on 16/01/2021.
//

import SwiftUI

struct ImageSliderItem: Identifiable {
  let id = UUID();
  let image: UIImage;
}

/**
  * https://stackoverflow.com/questions/58896661/swiftui-create-image-slider-with-dots-as-indicators
 */
struct ImageSliderView<Content>: View where Content: View {
  @Binding var currentIndex: Int;
  let maxIndex: Int;
  let displayProgressIndicator: Bool
  let content: () -> Content;
  
  @State var offset = CGFloat.zero;
  @State var dragging = false;
  
  init(currentIndex: Binding<Int>, maxIndex: Int, displayProgressIndicator: Bool = true, @ViewBuilder content: @escaping () -> Content) {
    self._currentIndex = currentIndex
    self.maxIndex = maxIndex
    self.displayProgressIndicator = displayProgressIndicator
    self.content = content;
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
            self.dragging = true
            self.offset = -CGFloat(self.currentIndex) * geometry.size.width + value.translation.width
          }).onEnded({ (value) in
            let predictedEndOffset = -CGFloat(self.currentIndex) * geometry.size.width + value.predictedEndTranslation.width
            let predictedIndex = Int(round(predictedEndOffset / -geometry.size.width))
            self.currentIndex = self.clampedIndex(from: predictedIndex)
            
            withAnimation(.easeOut) {
                self.dragging = false
            }
          }))
          .animation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0))
        }
      }
      if (maxIndex > 1 && displayProgressIndicator) {
        self.makePageIndicator(currentPage: self.currentIndex, pageCount: self.maxIndex + 1)
      }
    }.clipped()
  }
  
  func offset(in geometry: GeometryProxy) -> CGFloat {
    if self.dragging {
      return max(min(self.offset, 0), -CGFloat(self.maxIndex) * geometry.size.width)
    } else {
      return -CGFloat(self.currentIndex) * geometry.size.width
    }
  }
  
  func clampedIndex(from predictedIndex: Int) -> Int {
      let newIndex = min(max(predictedIndex, self.currentIndex - 1), self.currentIndex + 1)
      guard newIndex >= 0 else { return 0 }
      guard newIndex < maxIndex else { return maxIndex }
    
      return newIndex
  }
  
  func makePageIndicator(currentPage: Int, pageCount: Int) -> some View {
    return HStack(spacing: 8) {
      ForEach(0..<pageCount) { index in
        Rectangle()
          .foregroundColor(Color.white.opacity(currentPage == index ? 1 : 0))
          .background(BlurView(style: .systemUltraThinMaterial))
          .clipShape(Circle())
          .frame(width: 8, height: 8)
          .animation(.easeInOut)
      }
    }
    .padding(8)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
  }
}

struct ImageSliderView_Previews: PreviewProvider {
  @State var index = 0;
  static var previews: some View {
    ImageSliderView(currentIndex: Binding.constant(0), maxIndex: 5) {
      Image(uiImage: #imageLiteral(resourceName: "FREKVENS_table"))
        .resizable()
        .scaledToFill()
      Image(uiImage: #imageLiteral(resourceName: "FREKVENS_sofa"))
        .resizable()
        .scaledToFill()
      Image(uiImage: #imageLiteral(resourceName: "FREKVENS_light"))
        .resizable()
        .scaledToFill()
    }
    .background(Color.red)
    .frame(width: 300, height: 200)
  }
}
