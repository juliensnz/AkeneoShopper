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
let currentDeviceIsIphone = UIDevice.current.userInterfaceIdiom == .phone;
#else
let currentDeviceIsIpad = false
let currentDeviceIsIphone = false;
#endif

#if os(iOS)
//https://stackoverflow.com/questions/46192280/detect-if-the-device-is-iphone-x
var hasTopNotch: Bool {
  return UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.safeAreaInsets.top ?? 0 > 20
}
#endif

struct ContentView: View {
  #if os(iOS)
  @Environment(\.horizontalSizeClass) var horizontalSizeClass
  #endif
  
  @ViewBuilder
  var body: some View {
    #if os(iOS)
    if (horizontalSizeClass == .compact) {
      TabBar()
    } else {
      Sidebar()
    }
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
