//
//  ProductDetails.swift
//  AkeneoShopper
//
//  Created by Julien Sanchez on 20/01/2021.
//

import SwiftUI

struct ProductDetails: View {
  var namespace: Namespace.ID;
  var product: Product;
  let catalogContext: CatalogContext;
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
      .edgesIgnoringSafeArea(.all)
    #else
    content
    #endif
  }
  
  @ViewBuilder
  var content: some View {
    VStack {
      ScrollView {
        VStack {
          ProductHeader(product: product, isExpanded: true)
            .frame(height: 400)
            .matchedGeometryEffect(id: "header_\(product.id)", in: namespace)
          
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
    }
    .background(Color.white)
    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
  }
}

struct ProductDetails_Previews: PreviewProvider {
  @Namespace static var namespace;
  
  static var previews: some View {
    ProductDetails(namespace: namespace, product: productsData[0], catalogContext: catalogContext)
  }
}
