//
//  BuyView.swift
//  clearoutt
//
//  Created by Bolanle Adisa on 1/24/24.
//

// BuyView.swift
import SwiftUI
import FirebaseFirestore
import AVKit

struct BuyView: View {
    @State private var searchText = ""
    @State private var isCameraPresented = false
    @State private var selectedOption: String? = nil
    @State private var itemsForSaleAndRent: [ItemForSaleAndRent] = []
    @StateObject private var itemsManager = ItemsForSaleManager()
    @EnvironmentObject var cartManager: CartManager

    let options = ["Women's Clothes", "Men's Clothes", "Women's Shoes", "Men's Shoes", "Electronics", "Dorm Essentials", "Books"]

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
        .onAppear {
            NotificationCenter.default.addObserver(forName: NSNotification.Name("DidAddNewItem"), object: nil, queue: .main) { _ in
                self.fetchItemsForSale()
            }
            self.fetchItemsForSale()
        }

    }

    var titleAndWishListAndCartIcon: some View {
        HStack {
            Text("CLEAROUT")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Spacer()
            
            Button(action: {
                // Action for wishlist icon
            }) {
                Image(systemName: "heart.fill")
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
                ForEach(itemsForSaleAndRent) { item in
                    NavigationLink(destination: ItemCustomerView(item: item)) {
                        ItemCard(item: item)
                    }
                }
            }
            .padding([.horizontal, .top])
        }
        .background(Color(.systemGray6)) // Set background color for the scrollable part
    }

    private func fetchItemsForSale() {
        let db = Firestore.firestore()
        db.collection("itemsForSaleAndRent").getDocuments { (querySnapshot, err) in // Updated collection name
            if let err = err {
                print("Error getting documents: \(err)(BuyView)")
            } else if let querySnapshot = querySnapshot {
                print("Successfully fetched \(querySnapshot.documents.count) items(BuyView)")
                var mappedItems: [ItemForSaleAndRent] = []
                for document in querySnapshot.documents {
                    do {
                        let item = try document.data(as: ItemForSaleAndRent.self)
                        mappedItems.append(item)
                    } catch {
                        print("Failed to map document to ItemForSaleAndRent: \(error)(BuyView)")
                    }
                }
                self.itemsForSaleAndRent = mappedItems
                if self.itemsForSaleAndRent.isEmpty {
                    print("ItemsForSaleAndRent is empty after fetch(BuyView).")
                } else {
                    print("Mapped \(self.itemsForSaleAndRent.count) items successfully(BuyView).")
                }
            }
        }
    }
    
}

struct ItemCard: View {
    let item: ItemForSaleAndRent

    var body: some View {
        VStack {
            if item.isVideo {
                VideoPreview(url: URL(string: item.mediaUrl))
                    .frame(width: 150, height: 150)
                    .cornerRadius(10)
                    .clipped()
            } else {
                AsyncImage(url: URL(string: item.mediaUrl)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 200)
                            .cornerRadius(10)
                            .clipped()
                    case .failure(_), .empty:
                        Color.gray.opacity(0.1)
                            .frame(width: 150, height: 200)
                            .cornerRadius(10)
                    @unknown default:
                        EmptyView()
                    }
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                    .foregroundColor(.black)
                
                if let salePrice = item.price, salePrice > 0 {
                                    Text("Sale: $\(salePrice, specifier: "%.2f")")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                } else {
                                    Text("Sale: Not Applicable")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }

                                // Display rent price and period if available
                                if let rentPrice = item.rentPrice, rentPrice > 0, let rentPeriod = item.rentPeriod, rentPeriod != "Not Applicable" {
                                    Text("Rent: $\(rentPrice, specifier: "%.2f") / \(rentPeriod)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                } else if let rentPrice = item.rentPrice, rentPrice == 0 {
                                    Text("Rent: Not Applicable")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()

            HStack {
                Button(action: {
                    // Wishlist action
                }) {
                    Image(systemName: "heart")
                        .foregroundColor(.black)
                }
                .padding(.trailing, 100)

                Button(action: {
                    // Add to cart action
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

struct VideoPreview: View {
    let url: URL?
    
    var body: some View {
        VideoPlayer(player: AVPlayer(url: url ?? URL(string: "about:blank")!))
            .frame(width: 150, height: 150)
    }
}

struct BuyView_Previews: PreviewProvider {
    static var previews: some View {
        BuyView()
    }
}
