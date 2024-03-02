//
//  ItemCustomerView.swift
//  clearoutt
//
//  Created by Bolanle Adisa on 2/26/24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

struct ItemCustomerView: View {
    let item: ItemForSaleAndRent
    @State private var showingAddToCartConfirmation = false
    @State private var showingAddToWishlistConfirmation = false
    @EnvironmentObject var cartManager: CartManager

    var body: some View {
        ScrollView {
            VStack {
                mediaSection
                    .frame(height: 300)
                
                VStack(spacing: 16) {
                    HStack {
                        Text("Item Details")
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .padding(.bottom, 10)
                    
                    detailRow(title: "Name", value: item.name, icon: "tag")
                    detailRow(title: "Description", value: item.description ?? "No description", icon: "text.alignleft")
                    detailRow(title: "Sale Price", value: item.price ?? 0 > 0 ? String(format: "$%.2f", item.price!) : "Not Applicable", icon: "dollarsign.circle")
                    detailRow(title: "Rental Price", value: item.rentPrice ?? 0 > 0 ? String(format: "$%.2f", item.rentPrice!) : "Not Applicable", icon: "dollarsign.circle")
                    detailRow(title: "Rental Period", value: item.rentPeriod != nil && item.rentPeriod != "Not Applicable" ? item.rentPeriod! : "Not Applicable", icon: "calendar")
                    detailRow(title: "Size", value: item.size ?? "N/A", icon: "ruler")
                    detailRow(title: "Color", value: item.color ?? "No color specified", icon: "paintpalette")
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                .cornerRadius(12)
                .shadow(radius: 5)
                .padding()
                
                customerActions
            }
        }
        .navigationTitle("Item Details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder
    private var mediaSection: some View {
        if item.isVideo, let url = URL(string: item.mediaUrl) {
            VideoPlayerView(videoURL: url)
                .frame(height: 300)
                .cornerRadius(12)
                .aspectRatio(contentMode: .fit)
        } else if let url = URL(string: item.mediaUrl) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable()
                         .aspectRatio(contentMode: .fit)
                         .frame(height: 300)
                         .cornerRadius(12)
                case .failure(_):
                    Image(systemName: "photo")
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 300)
                default:
                    ProgressView()
                        .frame(height: 300)
                }
            }
        }
    }

    private func detailRow(title: String, value: String, icon: String) -> some View {
        HStack {
            Label(title, systemImage: icon)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
    }
    
    private var customerActions: some View {
        HStack(spacing: 20) {
            Button(action: {
                print("Add to Cart button tapped")
                cartManager.addToCart(item: item)
                print("Item supposed to be added to cart now")
                showingAddToCartConfirmation = true
                print("showingAddToCartConfirmation set to true, alert should be presented")
            }) {
                Text("Add to Cart")
                    .foregroundColor(.white)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .alert(isPresented: $showingAddToCartConfirmation) {
                Alert(
                    title: Text("Added to Cart"),
                    message: Text("\(item.name) has been added to your cart."),
                    dismissButton: .default(Text("OK"))
                )
            }

            Button(action: {
                showingAddToWishlistConfirmation = true
                print("Add to Wishlist button tapped")
            }) {
                Text("Add to Wishlist")
                    .foregroundColor(.white)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .padding(.top)
    }

}

struct ItemCustomerView_Previews: PreviewProvider {
    static var previews: some View {
        let dummyItem = ItemForSaleAndRent(
            id: "dummyID",
            name: "Sample Item",
            description: "This is a sample item for preview.",
            price: 99.99,
            size: "M",
            color: "Red",
            mediaUrl: "http://example.com/sample.jpg",
            isVideo: false,
            rentPrice: 0, // Assuming you have a rentPrice
            rentPeriod: "Not Applicable", // Assuming you have a rentPeriod
            userId: "user123"
        )
        ItemCustomerView(item: dummyItem).environmentObject(CartManager.shared)
    }
}
