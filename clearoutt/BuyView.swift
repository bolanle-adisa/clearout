//
//  BuyView.swift
//  clearoutt
//
//  Created by Bolanle Adisa on 1/24/24.
//

import SwiftUI

struct BuyView: View {
    @State private var searchText = ""
    @State private var isCameraPresented = false
    @State private var selectedOption: String? = nil
    let options = ["Trending", "Clothes", "Shoes", "Electronics", "Books"]

    struct Item: Identifiable {
        let id = UUID()
        let imageName: String
        let name: String
        let price: String
    }

    let mockData = [
        Item(imageName: "shirt", name: "Stylish Shirt", price: "$49.99"),
        Item(imageName: "shoes", name: "Running Shoes", price: "$89.99"),
        // Add more items as needed
    ]

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                titleAndWishListAndCartIcon
                searchBar
                optionsGroup
                itemsGrid
                Spacer()
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $isCameraPresented) {
            Text("Camera Functionality Here")
        }
    }

    var titleAndWishListAndCartIcon: some View {
        HStack {
            Text("CLEAROUT")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Spacer()
            
            Button(action: {
                // Action for the wishlist icon
            }) {
                Image(systemName: "heart.fill")
                    .foregroundColor(.black)
                    .imageScale(.large)
            }
            .padding(.trailing, 10) // Adjust trailing padding to increase spacing

            Button(action: {
                // Action for cart icon
            }) {
                Image(systemName: "cart.fill")
                    .foregroundColor(.black)
                    .imageScale(.large)
            }
            .padding(.trailing, 15)
        }
        .padding(.leading)
    }

    var searchBar: some View {
        HStack {
            TextField("Search", text: $searchText)
                .padding(9)
                .padding(.horizontal, 25)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(searchOverlayView)
        }
        .padding([.leading, .trailing])
    }

    var searchOverlayView: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .padding(.leading, 8)
            
            Spacer()
            
            if !searchText.isEmpty {
                Button(action: {
                    self.searchText = ""
                }) {
                    Image(systemName: "multiply.circle.fill")
                        .foregroundColor(.gray)
                }
            }
            
            Button(action: {
                self.isCameraPresented = true
            }) {
                Image(systemName: "camera.viewfinder")
                    .foregroundColor(.gray)
            }
            .padding(.trailing, 8)
        }
    }

    var optionsGroup: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        self.selectedOption = option
                    }) {
                        Text(option)
                            .fontWeight(.semibold)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(self.selectedOption == option ? LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing) : LinearGradient(gradient: Gradient(colors: [Color.white]), startPoint: .leading, endPoint: .trailing))
                            .foregroundColor(self.selectedOption == option ? .white : .black)
                            .cornerRadius(20)
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray, lineWidth: self.selectedOption == option ? 0 : 1))
                            .shadow(color: self.selectedOption == option ? Color.blue.opacity(0.5) : Color.clear, radius: 10, x: 0, y: 5)
                    }
                }
            }
            .padding(.vertical)
        }
        .padding(.leading)
    }

    var itemsGrid: some View {
        let columns = [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ]
        
        return ScrollView(.vertical, showsIndicators: false) {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(mockData) { item in
                    ItemCard(item: item)
                }
            }
            .padding([.horizontal, .top])
        }
        .background(Color(.systemGray6)) // Set background color for the scrollable part
    }
}

struct ItemCard: View {
    let item: BuyView.Item

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: item.imageName) // Replace with actual image loading mechanism
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .cornerRadius(10)

            Text(item.name)
                .font(.headline)
            
            Text(item.price)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Button(action: {
                    // Wishlist action
                }) {
                    Image(systemName: "heart")
                        .foregroundColor(.black)
                }
                .padding(.trailing, 100)

                Button(action: {
                    // Add to bag action
                }) {
                    Image(systemName: "cart")
                        .foregroundColor(.black)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        BuyView()
    }
}
