//
//  CloseButton.swift
//
//  Created by Julien Sanchez on 19/01/2021.
//

import SwiftUI

struct CircularButton: View {
  var icon: String
  var color: Color = Color.black.opacity(0.6)
  var action: () -> Void
  
  var body: some View {
    Button(action: action, label: {
      Image(systemName: self.icon)
        .font(.system(size: 17, weight: .bold))
        .frame(width: 15, height: 15)
        .foregroundColor(.white)
        .padding(10)
        .background(self.color)
        .clipShape(Circle())
    }).buttonStyle(BorderlessButtonStyle())
  }
}

struct CircularButton_Previews: PreviewProvider {
  static var previews: some View {
    CircularButton(icon: "xmark") {}
    CircularButton(icon: "arrow.up.left.and.arrow.down.right") {}
  }
}
