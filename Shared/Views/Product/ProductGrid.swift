//
//  ProductGrid.swift
//  AkeneoShopper
//
//  Created by Julien Sanchez on 19/01/2021.
//

import SwiftUI

struct ProductGrid: View {
  var products: [ProductListItem];
  @State var selectedProduct: ProductListItem? = nil
  @State var isGridDisabled = false;
  @State var showBarcodeScanner = false;
  @Namespace var namespace
  
  var body: some View {
    ZStack {
      #if os(iOS)
      ZStack {
        content
          .navigationBarHidden(selectedProduct != nil)
        fullContent
          .background(
            VisualEffectBlur(blurStyle: .systemUltraThinMaterial)
              .edgesIgnoringSafeArea(.all)
              .onTapGesture {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                  self.dismissModal()
                }
              })
      }
      .navigationBarTitle("Products")
      .toolbar(content: {
        ToolbarItem(placement: .navigationBarTrailing) {
          Image(systemName: "barcode")
            .onTapGesture {
              self.showBarcodeScanner = true
            }.sheet(isPresented: $showBarcodeScanner) {
              BarcodeScanner()
                .frame(height: 300)
            }
        }
      })
      
      #else
      ZStack {
        content
        fullContent
          .background(VisualEffectBlur().edgesIgnoringSafeArea(.all)
          .onTapGesture {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
              self.dismissModal()
            }
          })
      }
      .navigationTitle("Products")
      #endif
    }
  }
  
  @ViewBuilder
  var content: some View {
    ScrollView {
      LazyVGrid(columns: [
        GridItem(.adaptive(minimum: 300), spacing: 16)
      ], spacing: 16) {
        ForEach(self.products) { product in
          VStack {
            ProductHeader(product: product, isExpanded: false)
              .matchedGeometryEffect(id: "header_\(product.id)", in: namespace, isSource: self.selectedProduct == nil)
              .frame(height: 250)
              .onTapGesture {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                  self.selectedProduct = product
                  self.isGridDisabled = true
                }
              }
              .disabled(self.isGridDisabled)
          }
          .matchedGeometryEffect(id: "container_\(product.id)", in: namespace, isSource: self.selectedProduct == nil)
        }
      }
      .padding(.horizontal)
      .padding(.bottom)
      .padding(.top)
    }
    .zIndex(1)
  }
  
  @ViewBuilder
  var fullContent: some View {
    if let product = self.selectedProduct {
      ZStack(alignment: .topTrailing) {
        ProductDetails(namespace: namespace, product: product)
        
        CircularButton(icon: "xmark") {
          withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            self.dismissModal()
          }
        }
        .padding(16)
      }
      .zIndex(3)
      .padding(currentDeviceIsIpad ? 16 : 0)
      .frame(maxWidth: 712)
      .frame(maxWidth: .infinity)
    }
  }
  
  func dismissModal() {
    self.selectedProduct = nil
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
      self.isGridDisabled = false
    })
  }
}

struct ProductGrid_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      ProductGrid(products: productsData)
      ProductGrid(products: productsData)
        .previewDevice("iPhone 11")
    }
  }
}
