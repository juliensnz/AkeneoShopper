//
//  FilterDisplayView.swift
//  AkeneoShopper
//
//  Created by Julien Sanchez on 29/01/2021.
//

import SwiftUI

struct FilterDisplayView: View {
  var filter: ValueFilter;
  var catalogContext: CatalogContext;
  var onRemove: () -> Void;
  @State var isOpen = true;
  
  var body: some View {
    HStack(spacing: 0) {
      HStack(spacing: 3) {
        Text(filter.attribute.getLabel(locale: catalogContext.locale))
        Text(filter.filter.rawValue)
        Text(#""\#(filter.stringValue())""#)
      }
      .padding(.trailing, 8)
      .fixedSize()
      .font(.caption)
      .frame(maxWidth: self.isOpen ? nil : 0, alignment: .leading)
      .clipped()
      
      Button(action: {
        self.isOpen.toggle()
      }, label: {
        Image(systemName: "xmark")
          .font(.system(size: 11))
          .padding(8)
          .background(VisualEffectBlur())
          .clipShape(Circle())
          .onTapGesture {
            self.isOpen = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
              withAnimation {
                self.onRemove()
              }
            }
          }
      })
    }
    .padding(.leading, self.isOpen ? 14 : 2)
    .padding(.trailing, 2)
    .padding(.vertical, 2)
    .foregroundColor(Color.black)
    .background(Color.orange)
    .clipShape(
      RoundedRectangle(cornerRadius: 15, style: .continuous)
    )
    .animation(Animation.easeInOut(duration: 0.3))
    .opacity(self.isOpen ? 1 : 0)
    .animation(Animation.easeInOut(duration: 0.2).delay(0.3))
    .transition(.scale)
  }
}

struct FilterDisplayView_Previews: PreviewProvider {
  static var previews: some View {
    FilterDisplayView(filter: TextValueFilter(attribute: Attribute(
      code: "identifier",
      labels: ["en_US": "Identifier"],
      type: "pim_catalog_identifier",
      valuePerChannel: false,
      valuePerLocale: false
    ), filter: Operator.equal, value: "Nice"), catalogContext: CatalogContext(channel: "ecommerce", locale: "en_US"), onRemove: {print("closed")})
  }
}

