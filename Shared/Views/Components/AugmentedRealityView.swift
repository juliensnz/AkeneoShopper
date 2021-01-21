//
//  AugmentedRealityView.swift
//  AkeneoShopper
//
//  Created by Julien Sanchez on 18/01/2021.
//
//
//#if os(iOS) && !targetEnvironment(simulator)
//import SwiftUI
//import RealityKit
//import ARKit
//
//struct AugmentedRealityView: View {
//  @State var modelConfirmedForPlacement: String? = nil;
//  
//  var body: some View {
//    ZStack(alignment: .center) {
//      ARViewContainer(modelConfirmedForPlacement: $modelConfirmedForPlacement)
//      Button("place") {
//        self.modelConfirmedForPlacement = "Backpack.usdz"
//        print("Should place: \(modelConfirmedForPlacement)")
//      }
//    }
//  }
//}
//
//struct ARViewContainer: UIViewRepresentable {
//  @Binding var modelConfirmedForPlacement: String?;
//  
//  func updateUIView(_ uiView: UIViewType, context: Context) {
//    if let modelName = self.modelConfirmedForPlacement {
//      print("placing: \(modelName)")
//      
//      let modelEntity = try! ModelEntity.loadModel(named: modelName)
//      let anchorEntity = AnchorEntity()
//      
//      anchorEntity.addChild(modelEntity)
//      anchorEntity.transform.scale = SIMD3(x: 0.3, y: 0.3, z: 0.3)
//      
//      uiView.scene.addAnchor(anchorEntity)
//      
//      DispatchQueue.main.async {
//        self.modelConfirmedForPlacement = nil
//      }
//    } else {
//      print("nothing to place")
//    }
//  }
//  
//  func makeUIView(context: Context) -> some ARView {
//    let arView = ARView(frame: .zero);
//    
//    let config = ARWorldTrackingConfiguration()
//    config.planeDetection = [.horizontal]
//    config.environmentTexturing = .automatic;
//    if (ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh)) {
//      config.sceneReconstruction = .mesh
//    }
//    
//    arView.session.run(config)
//    
//    return arView;
//  }
//}
//
//struct AugmentedRealityView_Previews: PreviewProvider {
//  static var previews: some View {
//    AugmentedRealityView()
//  }
//}
//#endif
