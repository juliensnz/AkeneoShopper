//
//  Sidebar.swift
//  AkeneoShopper (iOS)
//
//  Created by Julien Sanchez on 16/01/2021.
//

import SwiftUI

struct Sidebar: View {
  @State var isConfigurationPopoverOpen = false;
  
  @ViewBuilder
  var body: some View {
    NavigationView {
      #if os(iOS)
      content
      #else
      content
        .frame(minWidth: 200, idealWidth: 250, maxWidth: 300)
        .toolbar(content: {
          ToolbarItem {
            HStack {
              Spacer()
              Button(action: {
                self.isConfigurationPopoverOpen = true;
              }) {
                Image(systemName: "gear")
              }.popover(isPresented: self.$isConfigurationPopoverOpen, content: {
                ApiConfigurationView()
              })
            }
          }
        })
      #endif
      
      ProductGrid(products: [])
    }
  }
  
  var content: some View {
    List {
      NavigationLink(destination: ProductGrid(products: [])) {
        Label("Products", systemImage: "doc.text.magnifyingglass")
      }
      
      #if os(iOS)
      NavigationLink(destination: ApiConfigurationView()) {
        Label("Configuration", systemImage: "gear")
      }
      #endif
      //      #if os(iOS) && !targetEnvironment(simulator)
      //      NavigationLink(destination: AugmentedRealityView()) {
      //        Label("Shoppings", systemImage: "bag")
      //      }
      //      #endif
      //      #if os(iOS)
      //      NavigationLink(destination: ProductGrid(products: productsData)) {
      //        Label("AnotherGrid", systemImage: "bag")
      //      }
      //      #endif
      //      #if os(iOS)
      //      NavigationLink(destination: BarcodeScanner()) {
      //        Label("Compare", systemImage: "guitars")
      //      }
      //      #endif
    }
    .listStyle(SidebarListStyle())
  }
}

struct Sidebar_Previews: PreviewProvider {
  static var previews: some View {
    Sidebar()
  }
}


let productsData: [Product] = [
  Product(identifier: "FREKVENS Lights", enabled: true, familyCode: "clothing", categoryCodes: ["FREKVENS", "Sales", "Party hard"], rawValues: [:], context: catalogContext),
  //  ProductListItem(identifier: "FREKVENS Plate", label: "FREKVENS Plate", enabled: true, family: nil, familyCode: "Interior", categories: ["FREKVENS"], values: [:]),
  //  ProductListItem(identifier: "FREKVENS Plate", label: "FREKVENS Plate", enabled: true, family: nil, familyCode: "Interior", categories: ["FREKVENS"], values: [:]),
  //  ProductListItem(identifier: "FREKVENS Plate", label: "FREKVENS Plate", enabled: true, family: nil, familyCode: "Interior", categories: ["FREKVENS"], values: [:]),
  //  ProductListItem(identifier: "FREKVENS Plate", label: "FREKVENS Plate", enabled: true, family: nil, familyCode: "Interior", categories: ["FREKVENS"], values: [:]),
  //  ProductListItem(identifier: "FREKVENS Plate", label: "FREKVENS Plate", enabled: true, family: nil, familyCode: "Interior", categories: ["FREKVENS"], values: [:]),
  //  ProductListItem(identifier: "FREKVENS Plate", label: "FREKVENS Plate", enabled: true, family: nil, familyCode: "Interior", categories: ["FREKVENS"], values: [:]),
  //  ProductListItem(identifier: "FREKVENS Plate", label: "FREKVENS Plate", enabled: true, family: nil, familyCode: "Interior", categories: ["FREKVENS"], values: [:]),
  //  ProductListItem(identifier: "FREKVENS Plate", label: "FREKVENS Plate", enabled: true, family: nil, familyCode: "Interior", categories: ["FREKVENS"], values: [:]),
  //  ProductListItem(identifier: "FREKVENS Plate", label: "FREKVENS Plate", enabled: true, family: nil, familyCode: "Interior", categories: ["FREKVENS"], values: [:]),
  //  ProductListItem(identifier: "FREKVENS Plate", label: "FREKVENS Plate", enabled: true, family: nil, familyCode: "Interior", categories: ["FREKVENS"], values: [:]),
  //  ProductListItem(identifier: "FREKVENS Mug", label: "FREKVENS Mug", enabled: true, family: nil, familyCode: "Kitchen", categories: ["FREKVENS"], values: [:])
].shuffled()

let picturesData = [#imageLiteral(resourceName: "FREKVENS_table"), #imageLiteral(resourceName: "FREKVENS_sofa"), #imageLiteral(resourceName: "FREKVENS_light"), #imageLiteral(resourceName: "FREKVENS_lights"), #imageLiteral(resourceName: "FREKVENS_table"), #imageLiteral(resourceName: "FREKVENS_speaker")].shuffled()

let familyColorsData = [Color(#colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)), Color(#colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1)), Color(#colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)), Color(#colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)), Color(#colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1))].shuffled()
let catalogContext = CatalogContext(channel: "ecommerce", locale: "en_US");
