//
//  ResponseHandler.swift
//  AkeneoShopper (iOS)
//
//  Created by Julien Sanchez on 22/01/2021.
//
import SwiftUI
import SwiftyJSON

enum ApiResponse {
  case success(data: JSON)
  case error(error: String)
}

class ResponseHandler {
  class func handleResponse(data: Data?, response: URLResponse?, error: Error?) -> ApiResponse {
    if let error = error {
      return ApiResponse.error(error: "Error: \(error)")
    }
    
    guard let data = data else {
      return ApiResponse.error(error: "Unable to parse received data for all products")
    }
    
    do {
      let result = try JSON(data: data)
      
      if let code = result["code"].int {
        guard let message = result["message"].string else {
          return ApiResponse.error(error: "\(code) error: unable to parse response message \(String(describing: result))")
        }
        
        return ApiResponse.error(error: "\(code) error: \(message)")
      }
      
      return ApiResponse.success(data: result);
    } catch {
      return ApiResponse.error(error: "error: \(error), \(data)")
    }
  }
}
