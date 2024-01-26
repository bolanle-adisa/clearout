//
//  ContentView.swift
//  clearoutt
//
//  Created by Bolanle Adisa on 1/22/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var userSession: UserSession
    @State private var selectedTab = 0
    @State private var showingProfile = false

    var body: some View {
        TabView(selection: $selectedTab) {
            BuyView()
                .tabItem {
                    Label("Buy", systemImage: "bag.fill")
                }
                .tag(0)

            RentView()
                .tabItem {
                    Label("Rent", systemImage: "hourglass.bottomhalf.fill")
                }
                .tag(1)

            SellView()
                .tabItem {
                    Label("Sell", systemImage: "tag.fill")
                }
                .tag(2)

            DonateView()
                .tabItem {
                    Label("Donate", systemImage: "gift.fill")
                }
                .tag(3)

            Group {
                if userSession.isAuthenticated {
                    UserProfileTwoView()
                } else {
                    UserProfileView(showingProfile: $showingProfile) // Pass the binding here
                        .environmentObject(userSession)
                }
            }
            .tabItem {
                Label("Me", systemImage: "person.crop.circle.fill")
            }
            .tag(4)
        }
        .onReceive(userSession.$isAuthenticated) { isAuthenticated in
            if isAuthenticated {
                selectedTab = 4
            }
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
