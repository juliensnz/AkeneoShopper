//
//  ContentView.swift
//  Shared
//
//  Created by Julien Sanchez on 15/01/2021.
//

import SwiftUI

let screen = UIScreen.main.bounds

struct ContentView: View {
  var body: some View {
    ProductView(products: ProductList(products: [
      ProductListItem(id: "my_unique_id", identifier: "FREKVENS", enabled: true, family: "Music", categories: ["FREKVENS"])
    ]));
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
