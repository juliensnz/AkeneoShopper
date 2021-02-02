//
//  ProductValueView.swift
//  AkeneoShopper
//
//  Created by Julien Sanchez on 01/02/2021.
//

import SwiftUI

struct ProductValueView: View {
  let value: ProductValue;
  let catalogContext: CatalogContext
  
  var body: some View {
    VStack(alignment: .leading) {
      HStack {
        Text(value.attribute.getLabel(locale: catalogContext.locale))
          .font(.title2)
        Spacer()
        if (value.channel != nil || value.locale != nil) {
          HStack {
            if let channel = value.channel {
              Text(channel)
                .font(.caption)
            }
            if let locale = value.locale {
              LocaleView(locale: locale)
                .font(.caption)
            }
          }
          .foregroundColor(Color.white)
          .padding(.vertical, 4)
          .padding(.horizontal, 8)
          .background(Color.blue)
          .clipShape(
            Capsule(style: .continuous)
          )
          .padding(.horizontal, 6)
          .padding(.vertical, 2)
        }
      }
      Text(value.stringValue())
        .padding(.top, 5)
        .font(.body)
        .lineLimit(.none)
    }
  }
}

struct ProductValueView_Previews: PreviewProvider {
  static var previews: some View {
    ProductValueView(value: TextProductValue(attribute: Attribute(
      code: "identifier",
      labels: ["en_US": "Identifier"],
      type: "pim_catalog_identifier",
      valuePerChannel: false,
      valuePerLocale: false
    ), channel: "ecommerce", locale: "en_US", text: "My value"), catalogContext: catalogContext)
  }
}
