//
//  SellView.swift
//  clearoutt
//
//  Created by Bolanle Adisa on 1/24/24.
//


import SwiftUI

struct SellView: View {
    @State private var itemsForSale: [ItemForSale] = []
    @State private var showingAddItemView = false

    var body: some View {
        VStack {
            Text("LISTINGS")
                .font(.headline)
                .fontWeight(.bold)
                .padding()

            Button(action: {
                showingAddItemView = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.white)
                    Text("Add Item")
                        .foregroundColor(.white)
                }
                .frame(minWidth: 0, maxWidth: .infinity)
                .padding()
                .background(Color.black)
                .cornerRadius(10)
            }
            .padding(.horizontal)

            List {
                ForEach(itemsForSale) { item in
                    HStack {
                        Text(item.name)
                            .foregroundColor(.gray)
                    }
                }
                .onDelete(perform: deleteItems)
            }
        }
        .sheet(isPresented: $showingAddItemView) {
            // Make sure you have defined your AddItemView correctly
            AddItemView(itemsForSale: $itemsForSale)
        }
    }

    func deleteItems(at offsets: IndexSet) {
        itemsForSale.remove(atOffsets: offsets)
    }
}

struct SellView_Previews: PreviewProvider {
    static var previews: some View {
        SellView()
    }
}
