//
//  SellView.swift
//  clearoutt
//
//  Created by Bolanle Adisa on 1/24/24.
//


import SwiftUI
import AVKit

struct SellView: View {
    @State private var itemsForSale: [ItemForSale] = []
    @State private var showingAddItemView = false
    @State private var selectedItem: ItemForSale?
    @State private var showDetailView = false
    @State private var showingDeleteConfirmation = false
    @State private var indexSetToDelete: IndexSet?

    var body: some View {
        NavigationView {
            VStack {
                Text("LISTINGS")
                    .font(.headline)
                    .fontWeight(.bold)
                    .padding()

                Button(action: {
                    showingAddItemView.toggle()
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill").foregroundColor(.white)
                        Text("Add Item").foregroundColor(.white)
                    }
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(10)
                }
                .padding(.horizontal)

                if itemsForSale.isEmpty {
                    Spacer()
                    Text("No items for sale. Tap on 'Add Item' to start selling.")
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Spacer()
                } else {
                    List {
                        ForEach(itemsForSale) { item in
                            HStack {
                                MediaView(item: item)
                                VStack(alignment: .leading) {
                                    Text(item.name).font(.headline)
                                    Text("$\(item.price, specifier: "%.2f")").font(.subheadline)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedItem = item
                                showDetailView = true
                            }
                            .contextMenu {
                                Button(action: {
                                    markItemAsSold(item: item)
                                }) {
                                    Label("Mark as Sold", systemImage: "checkmark.circle")
                                }
                            }
                        }
                        .onDelete(perform: deleteItems)
                    }
                }
            }
            .alert("Delete Item?", isPresented: $showingDeleteConfirmation, presenting: indexSetToDelete) { indexSet in
                Button("Delete", role: .destructive) {
                    itemsForSale.remove(atOffsets: indexSet)
                }
                Button("Cancel", role: .cancel) {}
            } message: { indexSet in
                Text("Are you sure you want to delete this item?")
            }
            .sheet(isPresented: $showingAddItemView) {
                AddItemView(itemsForSale: $itemsForSale)
            }
            .sheet(isPresented: $showDetailView) {
                if let selectedItem = selectedItem {
                    DetailView(selectedItem: $selectedItem)
                }
            }
        }
    }

    private func deleteItems(at offsets: IndexSet) {
        showingDeleteConfirmation = true
        indexSetToDelete = offsets
    }

    private func markItemAsSold(item: ItemForSale) {
        if let index = itemsForSale.firstIndex(where: { $0.id == item.id }) {
            itemsForSale.remove(at: index)
        }
    }
}

struct MediaView: View {
    let item: ItemForSale

    var body: some View {
        Group {
            if item.isVideo {
                Image(systemName: "video.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            } else {
                AsyncImage(url: URL(string: item.mediaUrl)) { phase in
                    switch phase {
                    case .empty: ProgressView()
                    case .success(let image): image.resizable().aspectRatio(contentMode: .fill).frame(width: 50, height: 50).clipShape(Circle())
                    case .failure: Image(systemName: "photo").resizable().frame(width: 50, height: 50).clipShape(Circle())
                    @unknown default: EmptyView()
                    }
                }
            }
        }
    }
}

struct DetailView: View {
    @Binding var selectedItem: ItemForSale?

    var body: some View {
        Group {
            if let selectedItem = selectedItem, let url = URL(string: selectedItem.mediaUrl) {
                if selectedItem.isVideo {
                    VideoPlayerView(videoURL: url)
                } else {
                    ImageViewer(urlString: selectedItem.mediaUrl)
                }
            } else {
                Text("No item selected")
            }
        }
    }
}

struct SellView_Previews: PreviewProvider {
    static var previews: some View {
        SellView()
    }
}
