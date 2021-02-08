//
//  TabBar.swift
//  AkeneoShopper (iOS)
//
//  Created by Julien Sanchez on 03/02/2021.
//

import SwiftUI

struct TabBar: View {
  var body: some View {
    TabView {
      NavigationView {
        ProductGrid(products: []).navigationBarTitle("Products")
      }
      .tabItem {
        Image(systemName: "doc.text.magnifyingglass")
        Text("Products")
      }
      
      NavigationView {
        ApiConfigurationView().navigationBarTitle("Settings")
      }
      .tabItem {
        Image(systemName: "gear")
        Text("Settings")
      }
    }
  }
}

struct TabBar_Previews: PreviewProvider {
  static var previews: some View {
    TabBar()
  }
}
