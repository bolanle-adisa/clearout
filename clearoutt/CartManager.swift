//
//  CartManager.swift
//  clearoutt
//
//  Created by Bolanle Adisa on 2/26/24.
//

import Foundation

class CartManager: ObservableObject {
    static let shared = CartManager()
    @Published var cartItems: [ItemForSaleAndRent] = []
    
    private init() {}
    
    func addToCart(item: ItemForSaleAndRent) {
        print("Attempting to add item to cart: \(item.name)")
        cartItems.append(item)
        print("Item added to cart. Total items now: \(cartItems.count)")
        // Optionally, here you could trigger a notification to the user
        // For example, using NotificationCenter or any other mechanism you prefer
    }
    
    func removeFromCart(itemID: String) {
        if let index = cartItems.firstIndex(where: { $0.id == itemID }) {
            print("Removing item from cart: \(cartItems[index].name)")
            cartItems.remove(at: index)
            print("Item removed. Total items now: \(cartItems.count)")
        } else {
            print("Item to remove not found in cart. Item ID: \(itemID)")
        }
    }
}
