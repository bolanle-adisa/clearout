//
//  clearouttApp.swift
//  clearoutt
//
//  Created by Bolanle Adisa on 1/22/24.
//

import SwiftUI
import Firebase
import FirebaseAuth

@main
struct clearouttApp: App {
    @StateObject var userSession = UserSession()
    @StateObject var cartManager = CartManager.shared

    init() {
        FirebaseApp.configure()
        // Initial authentication state set here, but dynamic changes are handled in ContentView
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userSession)
                .environmentObject(cartManager)
        }
    }
}
