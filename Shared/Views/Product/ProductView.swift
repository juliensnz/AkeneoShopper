//
//  ProductView.swift
//  AkeneoShopper (iOS)
//
//  Created by Julien Sanchez on 15/01/2021.
//

import SwiftUI

struct ProductView: View {
  @ObservedObject var productListStore: ProductListStore;
  
  init(products: ProductList = ProductList(products: [])) {
    productListStore = ProductListStore(defaultProducts: products)
  }
  
  var body: some View {
    ScrollView {
      VStack {
        ForEach(productListStore.productList.products) { product in
          ProductListItemView(product: product)
        }
      }.padding()
    }
  }
}

struct ProductView_Previews: PreviewProvider {
  static var previews: some View {
    ProductView(products: ProductList(products: [
      ProductListItem(id: "my_unique_id1", identifier: "FREKVENS Lights", enabled: true, family: "Music", categories: ["FREKVENS"]),
      ProductListItem(id: "my_unique_id2", identifier: "FREKVENS Plate", enabled: true, family: "Interior", categories: ["FREKVENS"]),
      ProductListItem(id: "my_unique_id3", identifier: "FREKVENS Mug", enabled: true, family: "Kitchen", categories: ["FREKVENS"])
    ]))
    .preferredColorScheme(.dark)
  }
}

struct ProductListItemView: View {
  let product: ProductListItem
  @State var isOpen: Bool = false;
  
  var body: some View {
    VStack {
      HStack(alignment: .top) {
        GeometryReader { geometry in
          ZStack {
            Image("FREKVENS_lights")
              .resizable()
              .aspectRatio(contentMode: .fill)
              .frame(width: isOpen ? geometry.size.width + 8 : 100, height: isOpen ? 250 : 100, alignment: .topLeading)
              .cornerRadius(10)
              .animation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0))
            
            VStack {
              HStack {
                Spacer()
                Text(product.family)
                  .padding(.horizontal, 10)
                  .padding(.vertical, 2)
                  .background(Color("family"))
                  .cornerRadius(10)
                  .padding(10)
                  .opacity(isOpen ? 1 : 0)
                  .animation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0))
              }
              Spacer()
            }
          }
        }
        .frame(width: isOpen ? .infinity : 100, height: isOpen ? 250 : 100, alignment: .topLeading)
        
        VStack(alignment: .leading) {
          HStack(alignment: .top) {
            Text(product.identifier)
              .font(.title)
              .fontWeight(.light)
              .lineLimit(1)
            Spacer()
            Text(product.family)
              .padding(.horizontal, 10)
              .padding(.vertical, 2)
              .background(Color("family").opacity(0.5))
              .cornerRadius(10)
              .frame(maxWidth: isOpen ? 0 : nil)
          }
          Text(product.categories[0])
          Spacer()
        }
        .opacity(isOpen ? 0 : 1)
        .frame(maxWidth: isOpen ? 0 : .infinity)
        .animation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0))
      }
      .onTapGesture {
        self.isOpen.toggle()
      }
      
      VStack(alignment: .leading) {
        Text(product.identifier)
          .font(.title)
          .fontWeight(.light)
        Text(product.categories[0])
        
        HStack(spacing: 20) {
          Spacer()
          HStack {
            Image(systemName: "star")
            Text("Favorite")
          }
          .padding()
          .background(LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)), Color(#colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1))]), startPoint: .topLeading, endPoint: .bottomTrailing))
          .cornerRadius(16)
          .shadow(color: Color(#colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)).opacity(0.5), radius: 10, x: 0.0, y: 0.0)
          
          Text("Add to Session")
          Spacer()
        }
        .padding(.vertical, 8)
        Spacer()
      }
      .opacity(isOpen ? 1 : 0)
      .frame(maxHeight: isOpen ? .infinity : 0)
      .animation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0))
    }
    .frame(maxHeight: isOpen ? 400 : nil)
  }
}
