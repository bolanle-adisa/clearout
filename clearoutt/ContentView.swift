//
//  ContentView.swift
//  clearoutt
//
//  Created by Bolanle Adisa on 1/22/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var userSession: UserSession

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            ShopView()
                .tabItem {
                    Label("Wishlist", systemImage: "heart.fill")
                }
                .tag(1)

            BagView()
                .tabItem {
                    Label("Sell", systemImage: "camera.fill")
                }
                .tag(2)

            WishlistView()
                .tabItem {
                    Label("Cart", systemImage: "cart.fill")
                }
                .tag(3)

            UserProfileView()
                .tabItem {
                    Label("Me", systemImage: "person.crop.circle.fill")
                }
                .tag(4)
        }
    }
}

// Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(UserSession())
    }
}

