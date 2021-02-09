//
//  ProductDetails.swift
//  AkeneoShopper
//
//  Created by Julien Sanchez on 20/01/2021.
//

import SwiftUI

struct ProductDetails: View {
  @Binding var product: Product?;
  let catalogContext: CatalogContext;
  let onClose: () -> Void
  var imageCount = 5;
  let pictures = [#imageLiteral(resourceName: "FREKVENS_table"), #imageLiteral(resourceName: "FREKVENS_sofa"), #imageLiteral(resourceName: "FREKVENS_light"), #imageLiteral(resourceName: "FREKVENS_lights"), #imageLiteral(resourceName: "FREKVENS_table"), #imageLiteral(resourceName: "FREKVENS_speaker")]
  
  #if os(iOS)
  var cornerRadius: CGFloat = 22
  #else
  var cornerRadius: CGFloat = 0
  #endif
  
  
  var body: some View {
    #if os(iOS)
    content
//      .edgesIgnoringSafeArea(.all)
    #else
    content.frame(minWidth: 800, idealWidth: 1000, maxWidth: .infinity, minHeight: 600, idealHeight: 800, maxHeight: .infinity, alignment: .center)
    #endif
  }
  
  @ViewBuilder
  var content: some View {
    VStack {
      if let product = self.product {
        ScrollView {
          VStack {
            ProductHeader(product: product, onClose: self.onClose)
              .frame(height: 400)
            VStack {
              ForEach (product.values) { value in
                VStack(alignment: .leading) {
                  ProductValueView(value: value, catalogContext: self.catalogContext)
                  Divider()
                }.padding(.horizontal, 8)
              }
              Spacer()
            }
          }
        }
      } else {
        VStack {
          Text("Loading...")
        }
      }
    }
    .background(Color("background_medium"))
  }
}
//
//struct ProductDetails_Previews: PreviewProvider {
//  @Namespace static var namespace;
//
//  static var previews: some View {
//    ProductDetails(product: productsData[0], catalogContext: catalogContext, onClose: {
//      print("Closed")
//    })
//    .previewLayout(.fixed(width: 500.0, height: 1000.0))
//  }
//}
