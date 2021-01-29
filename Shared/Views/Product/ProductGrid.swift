//
//  ProductGrid.swift
//  AkeneoShopper
//
//  Created by Julien Sanchez on 19/01/2021.
//

import SwiftUI

struct ProductGrid: View {
  @ObservedObject var productListStore: ProductListStore;
  
  @State var selectedProduct: Product? = nil
  @State var isGridDisabled = false;
  @State var showBarcodeScanner = false;
  @Namespace var namespace
  
  init(products: [Product] = []) {
    self.productListStore = ProductListStore(defaultProducts: products, catalogContext: catalogContext)
  }
  
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
              BarcodeScanner(action: { result in
                switch result {
                case .confirm(let identifier):
                  _ = AkeneoApi.sharedInstance.attribute.getIdentifier()
                    .sink { (attribute) in
                      
                      _ = self.productListStore.$products
                        .print("###########@")
                        .filter { $0.count == 1 }
                        .map({ products -> Product in
                          return products[0]
                        })
                        .assign(to: \.selectedProduct, on: self)
                      
                      self.productListStore.addFilter(filter: TextValueFilter(attribute: attribute, filter: Operator.equal, value: identifier))
                      print("add filter");
                      
                    }
                  print("Barcode confirmed: \(identifier)")
                default:
                  print("Barcode scanner dismissed")
                }
                
                self.showBarcodeScanner = false
              })
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
    VStack {
      ForEach(self.productListStore.valueFilters, id: \.self.id) { valueFilter in
        FilterDisplayView(filter: valueFilter, catalogContext: self.productListStore.catalogContext, onRemove: {
          self.productListStore.removeFilter(filter: valueFilter)
        })
      }
      ScrollView {
        LazyVGrid(columns: [
          GridItem(.adaptive(minimum: 300), spacing: 16)
        ], spacing: 16) {
          ForEach(self.productListStore.products) { product in
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
          }
        }
        .padding(.horizontal)
        .padding(.bottom)
        .padding(.top)
      }
      .zIndex(1)
    }
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
        .padding(8)
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
    }
  }
}
