//
//  UserSession.swift
//  clearoutt
//
//  Created by Bolanle Adisa on 1/22/24.
//

import Foundation

import SwiftUI

class UserSession: ObservableObject {
    // Add properties here to represent the user's session
    // For example, a simple isLoggedIn flag:
    @Published var isLoggedIn: Bool = false
    @Published var isAuthenticated = false

    // Add more properties and methods as needed
    
    func authenticateUser() {
            isAuthenticated = true
        }
}

