//
//  ItemDetailsView.swift
//  clearoutt
//
//  Created by Bolanle Adisa on 2/21/24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

struct ItemDetailsView: View {
    let item: ItemForSale
    @State private var showingMarkAsSoldConfirmation = false
    @State private var showingDeleteConfirmation = false

    var body: some View {
        ScrollView {
            VStack {
                mediaSection
                    .frame(height: 300)
                
                VStack(spacing: 16) {
                    HStack {
                        Text("Item Details")
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .padding(.bottom, 10)
                    
                    detailRow(title: "Name", value: item.name, icon: "tag")
                    detailRow(title: "Description", value: item.description, icon: "text.alignleft")
                    detailRow(title: "Price", value: String(format: "$%.2f", item.price), icon: "dollarsign.circle")
                    detailRow(title: "Size", value: item.size, icon: "ruler")
                    detailRow(title: "Color", value: item.color, icon: "paintpalette")
                    
                    if let timestamp = item.timestamp {
                        detailRow(title: "Posted on", value: timestamp, formatter: itemDateFormatter, icon: "calendar")
                    }
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                .cornerRadius(12)
                .shadow(radius: 5)
                .padding()
                
                actionButtons
            }
        }
        .navigationTitle("Item Details")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Have you sold this item?", isPresented: $showingMarkAsSoldConfirmation) {
            Button("Yes", role: .destructive, action: markAsSold)
            Button("No", role: .cancel) {}
        }
        .alert("You no longer want to sell this item?", isPresented: $showingDeleteConfirmation) {
            Button("Delete", role: .destructive, action: deleteItem)
            Button("Cancel", role: .cancel) {}
        }
    }
    
    @ViewBuilder
    private var mediaSection: some View {
        if item.isVideo, let url = URL(string: item.mediaUrl) {
            VideoPlayerView(videoURL: url)
                .frame(height: 300) // Specify a height to prevent it from taking the entire screen
                .cornerRadius(12)
                .aspectRatio(contentMode: .fit)
        } else if let url = URL(string: item.mediaUrl) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable()
                         .aspectRatio(contentMode: .fit)
                         .frame(height: 300)
                         .cornerRadius(12)
                case .failure(_):
                    Image(systemName: "photo")
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 300)
                default:
                    ProgressView()
                        .frame(height: 300)
                }
            }
        }
    }

    
    private func detailRow(title: String, value: String, icon: String) -> some View {
        HStack {
            Label(title, systemImage: icon)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
    }
    
    private func detailRow(title: String, value: Date, formatter: DateFormatter, icon: String) -> some View {
        HStack {
            Label(title, systemImage: icon)
                .foregroundColor(.secondary)
            Spacer()
            Text(value, formatter: formatter)
                .fontWeight(.semibold)
        }
    }
    
    private var actionButtons: some View {
            VStack(spacing: 20) {
                Button(action: { showingMarkAsSoldConfirmation = true }) {
                    Text("Mark as Sold")
                        .foregroundColor(.white)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(10)
                }
                .padding(.horizontal)

                Button(action: { showingDeleteConfirmation = true }) {
                    Text("Delete")
                        .foregroundColor(.white)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            .padding(.top)
        }
    
    private func markAsSold() {
            // Implement the functionality to mark the item as sold
            print("Item marked as sold")
        }
        
    private func deleteItem() {
        // Implement the functionality to delete the item
        print("Item deleted")
    }
}

let itemDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    formatter.timeStyle = .short
    return formatter
}()



struct ItemDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        let dummyItem = ItemForSale(id: "dummyID", name: "Sample Item", description: "This is a sample item for preview.", price: 99.99, size: "M", color: "Red", mediaUrl: "http://example.com/sample.jpg", isVideo: false, sellOrRent: "Sell", userId: "user123", timestamp: Date())
        ItemDetailsView(item: dummyItem)
    }
}
