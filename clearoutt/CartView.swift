//
//  CartView.swift
//  clearoutt
//
//  Created by Bolanle Adisa on 2/23/24.
//

import SwiftUI

struct CartView: View {
    @EnvironmentObject var cartManager: CartManager

    var body: some View {
        NavigationView {
            VStack {
                Text("My Cart")
                    .font(.headline)
                    .padding()
                if cartManager.cartItems.isEmpty {
                    // If the cart is empty, show a message
                    Text("Your cart is empty.\nStart shopping now!")
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(UIColor.systemBackground)) // Use the system background color
                } else {
                    List {
                        ForEach(cartManager.cartItems) { item in
                            HStack {
                                NavigationLink(destination: ItemCustomerView(item: item).environmentObject(cartManager)) {
                                    AsyncImage(url: URL(string: item.mediaUrl)) { phase in
                                        switch phase {
                                        case .success(let image):
                                            image.resizable().aspectRatio(contentMode: .fill).frame(width: 60, height: 60).cornerRadius(10)
                                        case .failure(_), .empty:
                                            Image(systemName: "photo").frame(width: 60, height: 60).background(Color.gray.opacity(0.1)).cornerRadius(10)
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                    
                                    VStack(alignment: .leading) {
                                        Text(item.name).font(.headline)
                                    
                                        Text("$\((item.price ?? 0.0), specifier: "%.2f")").font(.subheadline)
                                    }

                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    // Placeholder action for adding to wishlist
                                    print("Add \(item.name) to wishlist")
                                }) {
                                    Image(systemName: "heart")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        .onDelete(perform: removeItems)
                    }
                }

                let subtotal = cartManager.cartItems.reduce(0) { sum, item in
                    sum + (item.price ?? 0.0)
                }

                VStack {
                    HStack {
                        Text("Subtotal:")
                        Spacer()
                        Text("$\(subtotal, specifier: "%.2f")")
                    }
                    .padding()

                    Button("Checkout") {
                        // Implement checkout functionality
                        print("Proceed to checkout")
                    }
                    .foregroundColor(.white)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                .background(Color(UIColor.systemBackground))
            }
        }
    }

    func removeItems(at offsets: IndexSet) {
        offsets.forEach { index in
            let itemID = cartManager.cartItems[index].id ?? ""
            cartManager.removeFromCart(itemID: itemID)
        }
    }
}

struct CartView_Previews: PreviewProvider {
    static var previews: some View {
        CartView().environmentObject(CartManager.shared)
    }
}
