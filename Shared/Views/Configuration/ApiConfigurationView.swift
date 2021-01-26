//
//  ApiConfigurationView.swift
//  AkeneoShopper
//
//  Created by Julien Sanchez on 25/01/2021.
//

import SwiftUI


//@AppStorage("baseUrl") var baseUrl = "http://ped.test:8080"
//@AppStorage("clientID") var clientID = "1_16d23okvhfb44ccgo8s4wgoo8swocokcgsk0c0o4c084k00ks4"
//@AppStorage("secret") var secret = "2crnhds1wx5wocwsg4sw0cgwo0w0sckwcokg8go4sck8c44cso"
//@AppStorage("user") var user = "magento_0000"
//@AppStorage("password") var password = "2dpuj5tx4w4d"

struct ApiConfigurationView: View {
  @AppStorage("baseUrl") var baseUrl = "";
  @AppStorage("clientID") var clientID = "";
  @AppStorage("secret") var secret = "";
  @AppStorage("user") var user = "";
  @AppStorage("password") var password = "";
  
  var body: some View {
    VStack {
      VStack {
        Form {
          Section(header: Text("PIM authentication")) {
            HStack {
              Text("PIM Url")
                .frame(width: 100, alignment: .leading)
              TextField("https://my-pim.com", text: self.$baseUrl)
            }
            HStack {
              Text("Client Id")
                .frame(width: 100, alignment: .leading)
              TextField("1_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx", text: self.$clientID)
            }
            HStack {
              Text("Secret")
                .frame(width: 100, alignment: .leading)
              TextField("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx", text: self.$secret)
            }
            HStack {
              Text("Username")
                .frame(width: 100, alignment: .leading)
              TextField("myusername_0000", text: self.$user)
            }
            HStack {
              Text("Password")
                .frame(width: 100, alignment: .leading)
              SecureField("password", text: self.$password)
            }
          }
        }
        .padding()
      }.navigationTitle("Configuration")
    }
  }
}

struct ApiConfigurationView_Previews: PreviewProvider {
  static var previews: some View {
    ApiConfigurationView()
  }
}
