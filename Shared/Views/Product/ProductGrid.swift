//
//  ProductGrid.swift
//  AkeneoShopper
//
//  Created by Julien Sanchez on 19/01/2021.
//

import SwiftUI

struct ProductGrid: View {
  #if os(iOS)
  @Environment(\.horizontalSizeClass) var horizontalSizeClass
  #endif
  
  @Environment(\.colorScheme) var colorScheme
  
  @ObservedObject var productListStore: ProductListStore;
  
  @State var selectedProduct: Product? = nil
  @State var productDisplayed = false;
  @State var showBarcodeScanner = false;
  @Namespace var namespace
  
  init(products: [Product] = [], catalogContext: CatalogContext = CatalogContext(channel: "ecormerce", locale: "en_US"), valueFilters: [ValueFilter] = []) {
    self.productListStore = ProductListStore(defaultProducts: products, catalogContext: catalogContext, valueFilters: valueFilters)
  }
  
  var body: some View {
    ZStack {
      #if os(iOS)
      content
        .toolbar(content: {
          ToolbarItem {
            Image(systemName: "barcode")
              .onTapGesture {
                self.showBarcodeScanner = true
              }.sheet(isPresented: $showBarcodeScanner) {
                BarcodeScanner(action: { result in
                  switch result {
                  case .confirm(let identifier):
                    _ = AkeneoApi.sharedInstance.attribute.getIdentifier()
                      .sink { (attribute) in
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
      content
        .navigationTitle("Products")
      #endif
    }
  }
  
  @ViewBuilder
  var content: some View {
    VStack(spacing: 0) {
      HStack {
        ForEach(self.productListStore.valueFilters, id: \.self.id) { valueFilter in
          FilterDisplayView(filter: valueFilter, catalogContext: self.productListStore.catalogContext, onRemove: {
            self.productListStore.removeFilter(filter: valueFilter)
          })
        }
        Spacer()
      }.padding(self.productListStore.valueFilters.isEmpty ? 0 : 5)
      .animation(.easeInOut)
      
      ScrollView {
        LazyVGrid(columns: [
          GridItem(.adaptive(minimum: currentDeviceIsIphone ? 150 : 300), spacing: 16)
        ], spacing: 16) {
          ForEach(self.productListStore.products) { product in
            ProductCard(product: product)
              .sheet(isPresented: self.$productDisplayed, content: {
                ProductDetails(product: self.$selectedProduct, catalogContext: self.productListStore.catalogContext, onClose: {
                  withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    self.productDisplayed = false
                    self.selectedProduct = nil;
                  }
                })
              })
              .onTapGesture {
                print("on tap")
                self.selectedProduct = product
                self.productDisplayed = true
              }
              .shadow(color: Color(hue: product.familyColor, saturation: 0.43, brightness: 0.70).opacity(self.colorScheme == .dark ? 0.1 : 0.2), radius: 15, x: 0, y: 10)
          }
        }
        .padding(.horizontal)
        .padding(.bottom)
        .padding(.top)
      }
    }
  }
}

struct ProductGrid_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      ProductGrid(products: productsData, catalogContext: catalogContext, valueFilters: [TextValueFilter(attribute: Attribute(
        code: "identifier",
        labels: ["en_US": "Identifier"],
        type: "pim_catalog_identifier",
        valuePerChannel: false,
        valuePerLocale: false
      ), filter: Operator.equal, value: "9780761178972")])
    }
  }
}
