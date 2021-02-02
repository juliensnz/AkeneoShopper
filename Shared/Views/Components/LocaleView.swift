//
//  LocalView.swift
//  AkeneoShopper
//
//  Created by Julien Sanchez on 02/02/2021.
//

import SwiftUI

struct LocaleView: View {
  let language: String;
  let country: String?;
  
  init(locale: String) {
    let components = locale.components(separatedBy: "_")
    self.language = components.indices.contains(0) ? components[0] : locale;
    self.country = components.indices.contains(1) ? components[1] : nil;
  }
  
  var body: some View {
    HStack(spacing: 2) {
      Text(self.language)
      if let country = self.country {
        Text(self.flag(country: country))
      }
    }
  }
  
  func flag (country: String) -> String {
    let base : UInt32 = 127397
    var s = ""
    for v in country.unicodeScalars {
      s.unicodeScalars.append(UnicodeScalar(base + v.value)!)
    }
    return String(s)
  }
}

struct LocalView_Previews: PreviewProvider {
  static var previews: some View {
    LocaleView(locale: "en_US")
    LocaleView(locale: "fr_FR")
  }
}
