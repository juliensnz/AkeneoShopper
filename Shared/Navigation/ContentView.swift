//
//  ContentView.swift
//  Shared
//
//  Created by Julien Sanchez on 15/01/2021.
//

import SwiftUI

#if os(iOS)
let screen = UIScreen.main.bounds
// https://stackoverflow.com/questions/24059327/detect-current-device-with-ui-user-interface-idiom-in-swift
let currentDeviceIsIpad = UIDevice.current.userInterfaceIdiom == .pad;
#else
let currentDeviceIsIpad = false
#endif

#if os(iOS)
//https://stackoverflow.com/questions/46192280/detect-if-the-device-is-iphone-x
var hasTopNotch: Bool {
  return UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.safeAreaInsets.top ?? 0 > 20
}
#endif

struct ContentView: View {
  @ViewBuilder
  var body: some View {
    #if os(iOS)
    Sidebar()
    #else
    Sidebar()
      .frame(minWidth: 1000, minHeight: 600)
    #endif
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
