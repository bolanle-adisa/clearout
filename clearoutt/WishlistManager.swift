//
//  WishlistManager.swift
//  clearoutt
//
//  Created by Bolanle Adisa on 3/2/24.
//
import Foundation

class WishlistManager: ObservableObject {
    static let shared = WishlistManager()
    @Published var wishlistItems: [ItemForSaleAndRent] = []

    func addToWishlist(item: ItemForSaleAndRent) {
        DispatchQueue.main.async {
            self.performAddToWishlist(item: item)
        }
    }
    
    private func performAddToWishlist(item: ItemForSaleAndRent) {
        print("Attempting to add item to wishlist: \(item.name)")
        
        guard !self.wishlistItems.contains(where: { $0.id == item.id }) else {
            print("Item already in wishlist: \(item.name)")
            return
        }
        
        self.wishlistItems.append(item)
        print("Item successfully added to wishlist: \(item.name)")
        print("Completed addToWishlist method for item: \(item.name)")
    }
}
