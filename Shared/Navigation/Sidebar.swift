//
//  Sidebar.swift
//  AkeneoShopper (iOS)
//
//  Created by Julien Sanchez on 16/01/2021.
//

import SwiftUI

struct Sidebar: View {
  @ViewBuilder
  var body: some View {
    NavigationView {
      #if os(iOS)
      content
        .toolbar(content: {
          ToolbarItem(placement: .navigationBarTrailing) {
            Image(systemName: "gear")
          }
        })
        .navigationTitle("Shop")
      #else
      content
        .frame(minWidth: 200, idealWidth: 250, maxWidth: 300)
        .toolbar(content: {
          ToolbarItem(placement: .automatic) {
            Button(action: {}) {
              Image(systemName: "gear")
            }
          }
        })
      #endif
      
      ProductGrid(products: productsData)
    }
  }
  
  var content: some View {
    List {
      NavigationLink(destination: ProductGrid(products: productsData)) {
        Label("Products", systemImage: "doc.text.magnifyingglass")
      }
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


let productsData = [
  ProductListItem(id: "my_unique_id1", identifier: "FREKVENS Lights", label: "FREKVENS Lights", enabled: true, family: "Music", categories: ["FREKVENS", "Sales", "Party hard"]),
  ProductListItem(id: "my_unique_id2", identifier: "FREKVENS Plate", label: "FREKVENS Plate", enabled: true, family: "Interior", categories: ["FREKVENS"]),
  ProductListItem(id: "my_unique_id3", identifier: "FREKVENS Plate", label: "FREKVENS Plate", enabled: true, family: "Interior", categories: ["FREKVENS"]),
  ProductListItem(id: "my_unique_id4", identifier: "FREKVENS Plate", label: "FREKVENS Plate", enabled: true, family: "Interior", categories: ["FREKVENS"]),
  ProductListItem(id: "my_unique_id5", identifier: "FREKVENS Plate", label: "FREKVENS Plate", enabled: true, family: "Interior", categories: ["FREKVENS"]),
  ProductListItem(id: "my_unique_id6", identifier: "FREKVENS Plate", label: "FREKVENS Plate", enabled: true, family: "Interior", categories: ["FREKVENS"]),
  ProductListItem(id: "my_unique_id7", identifier: "FREKVENS Plate", label: "FREKVENS Plate", enabled: true, family: "Interior", categories: ["FREKVENS"]),
  ProductListItem(id: "my_unique_id8", identifier: "FREKVENS Plate", label: "FREKVENS Plate", enabled: true, family: "Interior", categories: ["FREKVENS"]),
  ProductListItem(id: "my_unique_id9", identifier: "FREKVENS Plate", label: "FREKVENS Plate", enabled: true, family: "Interior", categories: ["FREKVENS"]),
  ProductListItem(id: "my_unique_id10", identifier: "FREKVENS Plate", label: "FREKVENS Plate", enabled: true, family: "Interior", categories: ["FREKVENS"]),
  ProductListItem(id: "my_unique_id11", identifier: "FREKVENS Plate", label: "FREKVENS Plate", enabled: true, family: "Interior", categories: ["FREKVENS"]),
  ProductListItem(id: "my_unique_id12", identifier: "FREKVENS Mug", label: "FREKVENS Mug", enabled: true, family: "Kitchen", categories: ["FREKVENS"])
].shuffled()

let picturesData = [#imageLiteral(resourceName: "FREKVENS_table"), #imageLiteral(resourceName: "FREKVENS_sofa"), #imageLiteral(resourceName: "FREKVENS_light"), #imageLiteral(resourceName: "FREKVENS_lights"), #imageLiteral(resourceName: "FREKVENS_table"), #imageLiteral(resourceName: "FREKVENS_speaker")].shuffled()

let familyColorsData = [Color(#colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)), Color(#colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1)), Color(#colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)), Color(#colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)), Color(#colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1))].shuffled()
