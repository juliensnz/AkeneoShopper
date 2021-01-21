////
////  ProductDetails.swift
////  AkeneoShopper
////
////  Created by Julien Sanchez on 20/01/2021.
////
//
//import SwiftUI
//
//struct ProductItem: View {
//  var namespace: Namespace.ID;
//  @State var currentImage = 0;
//  var product: ProductListItem;
//  var isSource: Bool;
//  var imageCount = 5;
//  let pictures = [#imageLiteral(resourceName: "FREKVENS_table"), #imageLiteral(resourceName: "FREKVENS_sofa"), #imageLiteral(resourceName: "FREKVENS_light"), #imageLiteral(resourceName: "FREKVENS_lights"), #imageLiteral(resourceName: "FREKVENS_table"), #imageLiteral(resourceName: "FREKVENS_speaker")]
//  
//  var body: some View {
//    GeometryReader { geometry in
//      ZStack {
//        Image(uiImage: pictures[0])
//          .resizable()
//          .aspectRatio(contentMode: .fill)
//          .frame(width: geometry.size.width, height: geometry.size.height)
//          .matchedGeometryEffect(id: "image_\(product.id)_0", in: namespace, isSource: self.isSource)
//        
//        ZStack(alignment: .bottomLeading) {
//          Text("\(product.identifier)")
//            .matchedGeometryEffect(id: "label_\(product.id)", in: namespace, isSource: self.isSource)
//        }
//        .frame(width: geometry.size.width, height: geometry.size.height)
//      }
//      .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
//      .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
//      .frame(maxWidth: .infinity)
//      .matchedGeometryEffect(id: "container_\(product.id)", in: namespace, isSource: self.isSource)
//    }
//  }
//}
//
//struct ProductItem_Previews: PreviewProvider {
//  @Namespace static var namespace;
//  
//  static var previews: some View {
//    ProductItem(namespace: namespace, product: productsData[0], isSource: false)
//      .previewLayout(.fixed(width: 200.0, height: 200))
//  }
//}
