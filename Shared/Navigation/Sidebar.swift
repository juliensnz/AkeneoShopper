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
        .navigationTitle("Shop")
        .toolbar(content: {
          ToolbarItem(placement: .navigationBarTrailing) {
            Image(systemName: "gear")
          }
        })
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
    }
  }
  
  var content: some View {
    List {
      NavigationLink(destination: ProductView(products: ProductList(products: [
        ProductListItem(id: "my_unique_id1", identifier: "FREKVENS", label: "Frekvens light", enabled: true, family: "Music", categories: ["FREKVENS"]),
        ProductListItem(id: "my_unique_id2", identifier: "FREKVENS", label: "Frekvens light", enabled: true, family: "Music", categories: ["FREKVENS"]),
        ProductListItem(id: "my_unique_id3", identifier: "FREKVENS", label: "Frekvens light", enabled: true, family: "Music", categories: ["FREKVENS"]),
        ProductListItem(id: "my_unique_id4", identifier: "FREKVENS", label: "Frekvens light", enabled: true, family: "Music", categories: ["FREKVENS"])
      ]))) {
        Label("Products", systemImage: "doc.text.magnifyingglass")
      }
      NavigationLink(destination: AugmentedRealityView()) {
        Label("Shoppings", systemImage: "bag")
      }
      Label("Compare", systemImage: "guitars")
    }
    .listStyle(SidebarListStyle())
  }
}

struct Sidebar_Previews: PreviewProvider {
  static var previews: some View {
    Sidebar()
  }
}
