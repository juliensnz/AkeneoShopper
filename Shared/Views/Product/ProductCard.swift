//
//  ProductCard.swift
//  AkeneoShopper
//
//  Created by Julien Sanchez on 20/01/2021.
//

import SwiftUI
import SDWebImageSwiftUI

struct ProductCard: View {
  @ObservedObject var product: Product;
  @State var liked = false;
  
  var body: some View {
    GeometryReader { geometry in
      VStack(spacing: 4) {
        ZStack {
          self.image
            .frame(maxWidth: geometry.size.width - 16, maxHeight: 200)
            .background(VisualEffectBlur())
            .cornerRadius(15)
          
          VStack {
            Text(product.familyLabel)
              .padding(.vertical, 2)
              .padding(.horizontal, 8)
              .background(VisualEffectBlur())
              .clipShape(Capsule())
          }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
          .padding(6)
        }
        .frame(maxWidth: geometry.size.width - 16, maxHeight: 200)
        
        
        VStack(alignment: .leading, spacing: 0) {
          Text(product.label)
            .font(.title2)
            .fontWeight(.light)
            .lineLimit(1)
            .frame(maxWidth: .infinity, alignment: .bottomLeading)
            .truncationMode(.tail)
          
          Text(product.categoryLabels.joined(separator: ", "))
            .font(.caption)
            .lineLimit(1)
        }
        
        //      VStack {
        //        #if os(iOS)
        //        Button(action: {
        //          liked.toggle()
        //        }) {
        //          Image(systemName: "heart.fill")
        //            .foregroundColor(self.liked ? Color.red : Color.white)
        //            .shadow(color: Color.black.opacity(0.5), radius: 1)
        //        }
        //        .buttonStyle(BorderlessButtonStyle())
        //        #endif
        //        Spacer()
        //        ProductMetadata(product: product)
        //      }
        //      .animation(.none)
      }
      .padding(8)
      .background(VisualEffectBlur())
      .overlay(
        RoundedRectangle(cornerRadius: 20)
          .stroke(Color(hue: product.familyColor, saturation: 0.43, brightness: 0.70), lineWidth: 2)
      )
      .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
    .frame(height: 300)
  }
  
  @ViewBuilder
  var image: some View {
    if (self.product.images.isEmpty) {
      Image("placeholder")
        .resizable()
        .aspectRatio(contentMode: .fill)
    } else {
      WebImage(url: URL(string: self.product.images[0]))
        .resizable()
        .aspectRatio(contentMode: .fill)
    }
  }
}

struct ProductCard_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      ProductCard(product: productsData[0])
        .preferredColorScheme(.dark)
        .previewLayout(.fixed(width: 400, height: 300))
      ProductCard(product: productsData[0])
        .preferredColorScheme(.light)
        .previewLayout(.fixed(width: 400, height: 300))
      ProductCard(product: productsData[0])
        .previewLayout(.fixed(width: 150, height: 300))
    }
  }
}
