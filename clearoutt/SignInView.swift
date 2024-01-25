//
//  SignInView.swift
//  clearoutt
//
//  Created by Bolanle Adisa on 1/24/24.
//

import SwiftUI

struct SignInView: View {
    var email: String
    @State private var password: String = ""

    var body: some View {
        VStack {
            Text("Welcome Back!")
                .font(.headline)
                .padding()

            Text("Sign in to your account")
                .font(.subheadline)

            SecureField("Password", text: $password)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal)

            Button("Sign In") {
                signInUser(email: email, password: password)
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal)

            Spacer()
        }
    }

    private func signInUser(email: String, password: String) {
        // Implement Firebase sign-in logic here
    }
}

// Preview
struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView(email: "test@example.com")
    }
}
