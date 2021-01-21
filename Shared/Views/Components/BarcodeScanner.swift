//
//  BarcodeScanner.swift
//  AkeneoShopper (iOS)
//
//  Created by Julien Sanchez on 18/01/2021.
//

import SwiftUI
import CarBode
import AVFoundation //import to access barcode types you want to scan

enum BarcodeScanResult {
  case confirm(barcode: String)
  case dismiss
}

struct BarcodeScanner: View {
  @State var barcode: String? = nil
  var action: (_ result: BarcodeScanResult) -> Void
  
  var body: some View {
    ZStack(alignment: .bottom) {
      CBScanner(
        supportBarcode: .constant([.code128, .code39, .code93, .code39Mod43, .aztec, .ean13, .ean8, .interleaved2of5, .itf14, .pdf417, .upce, .qr]), //Set type of barcode you want to scan
        scanInterval: .constant(1.0) //Event will trigger every 5 seconds
      ) {
        if nil == self.barcode {
          self.barcode = $0.value;
        }
        //When the scanner found a barcode
        print("BarCodeType =",$0.type.rawValue, "Value =",$0.value)
      }
      onDraw: {
        //line width
        let lineWidth = 2
        
        //line color
        let lineColor = UIColor.red
        
        //Fill color with opacity
        //You also can use UIColor.clear if you don't want to draw fill color
        let fillColor = UIColor(red: 0, green: 1, blue: 0.2, alpha: 0.4)
        
        //Draw box
        $0.draw(lineWidth: CGFloat(lineWidth), lineColor: lineColor, fillColor: fillColor)
      }
      .edgesIgnoringSafeArea(.all)
      
      ZStack(alignment: .topTrailing) {
        CircularButton(icon: "xmark") {
          self.barcode = nil
          action(BarcodeScanResult.dismiss)
        }
        .padding()
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
      
      VStack(spacing: 4) {
        Text("Aim at a barcode")
          .font(.caption)
          .foregroundColor(Color.white)
        Color.black.opacity(0.1)
          .frame(width: 250, height: 150)
          .overlay(
            RoundedRectangle(cornerRadius: 16)
              .stroke(Color.white, lineWidth: 2)
          ).clipShape(
            RoundedRectangle(cornerRadius: 16))
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      
      VStack(spacing: 20) {
        Text("Scanned barcode:")
          .font(.title)
        Text(nil == self.barcode ? "" : self.barcode!)
          .font(.system(size: 20, design: .monospaced))
          .padding(10)
          .background(Color.white.opacity(0.1))
          .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        HStack(spacing: 40) {
          CircularButton(icon: "xmark", color: Color.red) {
            self.barcode = nil
          }
          CircularButton(icon: "checkmark", color: Color.green) {
            if let barcode = self.barcode {
              action(BarcodeScanResult.confirm(barcode: barcode))
            }
          }
        }
      }
      .padding(.vertical)
      .padding(.horizontal, 30)
      .background(VisualEffectBlur(blurStyle: .systemUltraThinMaterial))
      .clipShape(RoundedRectangle(cornerRadius: 25.0, style: .continuous))
      .offset(y: nil == self.barcode ? screen.height : -50)
      .animation(.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0))
      .edgesIgnoringSafeArea(.all)
    }
  }
  
  func generateBarcode(from string: String) -> UIImage? {
    let data = string.data(using: String.Encoding.ascii)
    
    if let filter = CIFilter(name: "CICode128BarcodeGenerator") {
      filter.setValue(data, forKey: "inputMessage")
      let transform = CGAffineTransform(scaleX: 3, y: 3)
      
      if let output = filter.outputImage?.transformed(by: transform) {
        return UIImage(ciImage: output)
      }
    }
    
    return nil
  }
}


struct BarcodeScanner_Previews: PreviewProvider {
  static var previews: some View {
    BarcodeScanner(action: {_ in})
  }
}
