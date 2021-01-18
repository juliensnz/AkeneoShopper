//
//  ARModel.swift
//  AkeneoShopper (iOS)
//
//  Created by Julien Sanchez on 18/01/2021.
//

import UIKit
import RealityKit
import Combine

class ARModel {
  var modelName: String;
  var modelEntity: ModelEntity?;
  
  private var cancellable: AnyCancellable? = nil
  
  init(modelName: String) {
    self.modelName = modelName;
    
    self.cancellable = ModelEntity.loadModelAsync(named: modelName).sink(receiveCompletion: { (loadCompletion) in
      print("Cannot load \(loadCompletion)")
    }, receiveValue: { (modelEntity) in
      print("Model loaded \(modelEntity)")
      self.modelEntity = modelEntity
    })
  }
}
