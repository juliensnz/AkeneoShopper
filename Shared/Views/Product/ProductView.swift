//
//  ProductView.swift
//  AkeneoShopper (iOS)
//
//  Created by Julien Sanchez on 15/01/2021.
//

import SwiftUI

struct ProductView: View {
  @ObservedObject var productListStore: ProductListStore;
  @State var likedProducts: [String] = [];
  @State var isSettingsOpen = false;
  @State var compactView = true;
  @State var expandedProducts: [String] = []
  
  init(products: ProductList = ProductList(products: [])) {
    productListStore = ProductListStore(defaultProducts: products)
  }
  
  var body: some View {
    ZStack {
      Color("background_heavy")
        .edgesIgnoringSafeArea(.all)
      
      GeometryReader { geometry in
        VStack(spacing: 0) {
          VStack {
            HStack {
              Text("Products")
                .font(.title)
                .bold()
                .onTapGesture {
                  isSettingsOpen.toggle()
                }
              Spacer()
              Image(systemName: "slider.horizontal.3")
                .font(.title2)
                .onTapGesture {
                  self.isSettingsOpen.toggle()
                }
            }.padding(.horizontal)
          }
          .zIndex(1)
          .padding(.top, 50)
          .padding(.bottom, 5)
          .background(Color("background_light"))
          
          VStack {
            HStack {
              Text("Compact view")
              Spacer()
              Toggle("", isOn: self.$compactView)
                .onChange(of: self.compactView) { newValue in
                  if (newValue) {
                    self.expandedProducts = []
                  } else {
                    self.expandedProducts = productListStore.productList.products.map({ (product) -> String in
                      return product.id
                    })
                  }
                }
            }
          }
          .padding()
          .frame(minWidth: 300, maxWidth: geometry.size.width * 0.8)
          .frame(height: self.isSettingsOpen ? nil : 0)
          .background(Color("background_light"))
          .clipShape(RoundedRectangle(cornerRadius: 20))
          .padding(self.isSettingsOpen ? 16 : 0)
          .opacity(self.isSettingsOpen ? 1 : 0)
          .shadow(color: Color.black.opacity(self.isSettingsOpen ? 0.2 : 0), radius: 20, x: 0.0, y: 10)
          .offset(y: self.isSettingsOpen ? 0 : -500)
          .animation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0))
          
          ProductListView(productListStore: self.productListStore, likedProducts: self.$likedProducts, expandedProducts: self.$expandedProducts)
            .background(Color("background_light"))
            .clipShape(RoundedRectangle(cornerRadius: self.isSettingsOpen ? 20 : 0))
            .rotation3DEffect(
              Angle(degrees: self.isSettingsOpen ? 10 : 0),
              axis: (x: 1.0, y: 0, z: 0.0)
            )
            .scaleEffect(self.isSettingsOpen ? 0.9 : 1)
            .shadow(color: Color.black.opacity(self.isSettingsOpen ? 0.2 : 0), radius: 20, x: 0.0, y: 10)
            .animation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0))
            .offset(y: self.isSettingsOpen ? -50 : 0)
            .edgesIgnoringSafeArea(.all)
        }
        
      }
      .edgesIgnoringSafeArea(.all)
    }
  }
}

struct ProductListView: View {
  @ObservedObject var productListStore: ProductListStore;
  @Binding var likedProducts: [String];
  @Binding var expandedProducts: [String];
  
  var body: some View {
    ScrollView {
      VStack {
        ForEach(productListStore.productList.products) { product in
          ProductListItemView(product: product, likedProducts: $likedProducts, expandedProducts: $expandedProducts)
        }
      }.padding()
    }
  }
}


struct ProductView_Previews: PreviewProvider {
  static var previews: some View {
    ProductView(products: ProductList(products: [
      ProductListItem(id: "my_unique_id1", identifier: "FREKVENS Lights", label: "FREKVENS Lights", enabled: true, family: "Music", categories: ["FREKVENS", "Sales", "Party hard"]),
      ProductListItem(id: "my_unique_id2", identifier: "FREKVENS Plate", label: "FREKVENS Plate", enabled: true, family: "Interior", categories: ["FREKVENS"]),
      ProductListItem(id: "my_unique_id3", identifier: "FREKVENS Mug", label: "FREKVENS Mug", enabled: true, family: "Kitchen", categories: ["FREKVENS"])
    ]))
    ProductView(products: ProductList(products: [
      ProductListItem(id: "my_unique_id1", identifier: "FREKVENS Lights", label: "FREKVENS Lights", enabled: true, family: "Music", categories: ["FREKVENS", "Sales", "Party hard"]),
      ProductListItem(id: "my_unique_id2", identifier: "FREKVENS Plate", label: "FREKVENS Plate", enabled: true, family: "Interior", categories: ["FREKVENS"]),
      ProductListItem(id: "my_unique_id3", identifier: "FREKVENS Mug", label: "FREKVENS Mug", enabled: true, family: "Kitchen", categories: ["FREKVENS"])
    ]))
    .preferredColorScheme(.dark)
  }
}

struct ProductListItemView: View {
  let product: ProductListItem
  @Binding var likedProducts: [String];
  @Binding var expandedProducts: [String];
  @State var currentIndex: Int = 0;
  let familyColors = [Color(#colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)), Color(#colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1)), Color(#colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)), Color(#colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)), Color(#colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1))]
  let pictures = [#imageLiteral(resourceName: "FREKVENS_table"), #imageLiteral(resourceName: "FREKVENS_sofa"), #imageLiteral(resourceName: "FREKVENS_light"), #imageLiteral(resourceName: "FREKVENS_lights"), #imageLiteral(resourceName: "FREKVENS_table"), #imageLiteral(resourceName: "FREKVENS_speaker")].shuffled()
  
  init(product: ProductListItem, likedProducts: Binding<[String]>, expandedProducts: Binding<[String]>) {
    self.product = product;
    self._likedProducts = likedProducts;
    self._expandedProducts = expandedProducts
    self.currentIndex = Int.random(in: 0..<pictures.count)
  }
  
  var body: some View {
    let isOpen = self.expandedProducts.contains(self.product.id);
    
    VStack {
      HStack(alignment: .top) {
        self.makeImageView(isOpen: isOpen)
        
        if !isOpen {
          self.makeSummary(isOpen: isOpen)
        }
      }
      .onTapGesture {
        if (!isOpen) {
          self.expandedProducts.append(self.product.id)
        } else {
          self.expandedProducts = self.expandedProducts.filter { (id) -> Bool in
            return id != self.product.id
          }
        }
      }
      
      self.makeExpandedCard(isOpen: isOpen)
    }
    .animation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0))
  }
  
  func makeImageView (isOpen: Bool) -> some View {
    let isLiked = self.likedProducts.contains(self.product.id)
    
    return ZStack {
      ImageSliderView(
        currentIndex: self.$currentIndex,
        maxIndex: pictures.count - 1,
        displayProgressIndicator: isOpen
      ) {
        ForEach(0..<pictures.count) { index in
          Image(uiImage: pictures[index])
            .resizable()
            .scaledToFill()
        }
      }
      .frame(width: isOpen ? nil : 100, height: isOpen ? 250 : 100, alignment: .center)
      .animation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0))
      .cornerRadius(10)
      
      if (isOpen) {
        VStack {
          HStack {
            Text(product.family)
              .padding(.horizontal, 10)
              .padding(.vertical, 2)
              .background(self.familyColors.randomElement())
              .cornerRadius(10)
              .padding(10)
            Spacer()
            Image(systemName: isLiked ? "heart.fill" : "heart")
              .font(.system(size: 24))
              .padding(.horizontal, 10)
              .onTapGesture {
                if !isLiked {
                  self.likedProducts.append(self.product.id);
                } else {
                  self.likedProducts = self.likedProducts.filter({
                    $0 != self.product.id
                  })
                }
              }
          }
          Spacer()
        }
        .opacity(isOpen ? 1 : 0)
        .offset(y: isOpen ? 0 : -50)
      }
    }
  }
  
  func makeSummary(isOpen: Bool) -> some View {
    return VStack(alignment: .leading) {
      HStack(alignment: .top) {
        Text(product.identifier)
          .font(.title2)
          .fontWeight(.light)
          .lineLimit(1)
        Spacer()
        Text(product.family)
          .font(.footnote)
          .padding(.horizontal, 10)
          .padding(.vertical, 2)
          .background(self.familyColors.randomElement().opacity(0.5))
          .cornerRadius(10)
          .frame(maxWidth: isOpen ? 0 : nil)
      }
      Text(product.categories.joined(separator: ", "))
        .font(.caption)
      Spacer()
    }
    .transition(AnyTransition.opacity.combined(with: AnyTransition.move(edge: .trailing)))
    .opacity(isOpen ? 0 : 1)
  }
  
  func makeExpandedCard(isOpen: Bool) -> some View {
    return VStack(alignment: .leading) {
      HStack {
        Text(product.identifier)
          .font(.title)
          .fontWeight(.light)
        Text(product.categories[0])
        Spacer()
      }
      
//      HStack(spacing: 20) {
//        Spacer()
//        HStack {
//          Image(systemName: "star")
//          Text("Favorite")
//        }
//        .padding()
//        .background(LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)), Color(#colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1))]), startPoint: .topLeading, endPoint: .bottomTrailing))
//        .cornerRadius(16)
//        .shadow(color: Color(#colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)).opacity(0.5), radius: 10, x: 0.0, y: 0.0)
//
//        Text("Add to Session")
//        Spacer()
//      }
//      .padding(.vertical, 8)
//      Spacer()
    }
    .opacity(isOpen ? 1 : 0)
    .frame(maxHeight: isOpen ? .infinity : 0)
    .animation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0))
  }
}
