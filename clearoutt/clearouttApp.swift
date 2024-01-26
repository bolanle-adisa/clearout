//
//  clearouttApp.swift
//  clearoutt
//
//  Created by Bolanle Adisa on 1/22/24.
//

import SwiftUI
import Firebase

@main
struct clearouttApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
            .environmentObject(UserSession())
        }
    }
}

