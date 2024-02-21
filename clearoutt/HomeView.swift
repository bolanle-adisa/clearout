//
//  HomeView.swift
//  clearoutt
//
//  Created by Bolanle Adisa on 1/22/24.
//

import SwiftUI

struct HomeView: View {
    @State private var searchText = ""
    @State private var isCameraPresented = false
    @State private var selectedOption: String? = nil
    let options = ["Trending", "Clothes", "Shoes", "Electronics", "Books"]

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                // Title and message icon
                titleAndMessageIcon

                // Search bar
                searchBar
                
                // Options group
                optionsGroup

                Spacer() // Pushes everything to the top
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $isCameraPresented) {
            // Implement your camera functionality here
            Text("Camera Functionality Here")
        }
    }
    
    var titleAndMessageIcon: some View {
        HStack {
            Text("CLEAROUT")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Spacer()
            
            Button(action: {
                // Action for the messaging icon
            }) {
                Image(systemName: "message")
                    .foregroundColor(.black)
                    .imageScale(.large)
                    .padding(.trailing)
            }
        }
        .padding(.leading)
    }
    
    var searchBar: some View {
        HStack {
            TextField("Search", text: $searchText)
                .padding(9)
                .padding(.horizontal, 25)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    searchOverlayView
                )
        }
        .padding([.leading, .trailing])
    }
    
    var searchOverlayView: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .padding(.leading, 8)
            
            Spacer()
            
            if !searchText.isEmpty {
                Button(action: {
                    self.searchText = ""
                }) {
                    Image(systemName: "multiply.circle.fill")
                        .foregroundColor(.gray)
                }
            }
            
            Button(action: {
                self.isCameraPresented = true
            }) {
                Image(systemName: "camera.viewfinder")
                    .foregroundColor(.gray)
            }
            .padding(.trailing, 8)
        }
    }
    
    var optionsGroup: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(options, id: \.self) { option in
                    OptionButton(option: option, isSelected: selectedOption == option) {
                        self.selectedOption = option
                    }
                }
            }
            .padding(.vertical)
        }
        .padding(.leading)
    }
}

struct OptionButton: View {
    let option: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(option)
                .fontWeight(.semibold)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(background)
                .foregroundColor(isSelected ? .white : .black)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray, lineWidth: isSelected ? 0 : 1)
                )
                .shadow(color: isSelected ? Color.blue.opacity(0.5) : Color.clear, radius: 10, x: 0, y: 5)
        }
    }

    var background: LinearGradient {
        isSelected
            ? LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing)
            : LinearGradient(gradient: Gradient(colors: [Color.white]), startPoint: .leading, endPoint: .trailing)
    }
}


struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
