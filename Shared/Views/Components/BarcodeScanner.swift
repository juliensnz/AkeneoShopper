//
//  BarcodeScanner.swift
//  AkeneoShopper (iOS)
//
//  Created by Julien Sanchez on 18/01/2021.
//

import SwiftUI
import CarBode
import AVFoundation //import to access barcode types you want to scan

struct BarcodeScanner: View {
  @State var barcode: String? = nil
  
  var body: some View {
    ZStack {
      CBScanner(
        supportBarcode: .constant([.code128]), //Set type of barcode you want to scan
        scanInterval: .constant(5.0) //Event will trigger every 5 seconds
      ){
        barcode = $0.value;
        //When the scanner found a barcode
        print("BarCodeType =",$0.type.rawValue, "Value =",$0.value)
      }
      onDraw: {
        //      print("Preview View Size = \($0.cameraPreviewView.bounds)")
        //      print("Barcode Corners = \($0.corners)")
        
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
      if nil != self.barcode {
        Text("Bar code: \(barcode!)")
      }
    }
    
  }
}
