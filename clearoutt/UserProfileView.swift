//
//  UserProfileView.swift
//  clearoutt
//
//  Created by Bolanle Adisa on 1/22/24.
//

import SwiftUI

struct UserProfileView: View {
    @State private var emailAddress: String = ""
    
    var body: some View {
        VStack {
            Text("SIGN IN OR CREATE ACCOUNT")
                .font(.headline)
                .fontWeight(.bold)
                .padding()
            
            TextField("Email address", text: $emailAddress)
                .textFieldStyle(.roundedBorder)
                .padding()
            
            Button("Continue") {
                // Handle continue action
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding()
            .background(Color.black)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal)

            
//            Text("By selecting Create Account you agree to our Privacy Policy and Terms & Conditions")
//                .font(.footnote)
//                .foregroundColor(.gray)
//                .padding()
            
            List {
                SettingRow(icon: "message", title: "Messages")
                                SettingRow(icon: "bell", title: "Notifications")
                                SettingRow(icon: "map", title: "Addresses")
                                SettingRow(icon: "creditcard", title: "Payment Method")
                                SettingRow(icon: "list.bullet.rectangle.portrait", title: "Transaction History")
                                SettingRow(icon: "questionmark.circle", title: "Help Center")
                                SettingRow(icon: "gearshape", title: "Settings")
            }
            
            Spacer() // Pushes everything to the top
            
        }
    }
}

struct SettingRow: View {
    let icon: String
    let title: String
    let detail: String?
    
    init(icon: String, title: String, detail: String? = nil) {
        self.icon = icon
        self.title = title
        self.detail = detail
    }
    
    var body: some View {
        HStack {
            Image(systemName: icon)
            Text(title)
            Spacer()
            if let detail = detail {
                Text(detail)
                    .foregroundColor(.gray)
            }
            Image(systemName: "chevron.right")
        }
        .padding()
    }
}

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileView()
    }
}
