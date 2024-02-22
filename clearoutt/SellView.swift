//
//  SellView.swift
//  clearoutt
//
//  Created by Bolanle Adisa on 1/24/24.
//


import SwiftUI
import AVKit
import FirebaseFirestore
import FirebaseAuth

struct SellView: View {
    @State private var itemsForSale: [ItemForSale] = []
    @State private var showingAddItemView = false
    @State private var selectedItem: ItemForSale?
    @EnvironmentObject var userSession: UserSession
    @State private var showingLoginAlert = false
    @State private var showingItemDetailsView = false

    var body: some View {
        NavigationView {
            VStack {
                Text("LISTINGS")
                    .font(.headline)
                    .fontWeight(.bold)
                    .padding()
                
                Button(action: {
                    if userSession.isAuthenticated {
                        showingAddItemView.toggle()
                    } else {
                        showingLoginAlert = true
                    }
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
                .alert(isPresented: $showingLoginAlert) {
                    Alert(
                        title: Text("Not Logged In"),
                        message: Text("You must be logged in to add an item."),
                        dismissButton: .default(Text("OK"))
                    )
                }
                
                if itemsForSale.isEmpty {
                    Spacer()
                    Text("No items for sale. Tap on 'Add Item' to start selling.")
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Spacer()
                } else {
                    List(itemsForSale) { item in
                        ZStack {
                            ItemRow(item: item)
                            .frame(minHeight: 80)

                            Button(action: {
                                self.selectedItem = item
                                self.showingItemDetailsView = true
                            }) {
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                        }
                        .listRowInsets(EdgeInsets())
                    }
                    
                    Spacer();
                }
            }
        
            .sheet(isPresented: $showingAddItemView) {
                AddItemView(itemsForSale: $itemsForSale).environmentObject(userSession)
            }
            
            .sheet(isPresented: $showingItemDetailsView) {
                if let selectedItem = selectedItem {
                    ItemDetailsView(item: selectedItem)
                }
            }
            .onAppear {
                fetchItemsForSale()
            }
            onReceive(userSession.$isAuthenticated) { isAuthenticated in
                if !isAuthenticated {
                    self.itemsForSale.removeAll() // Clear items if the user logs out
                }
            }
        }
    }
    
    private func itemRow(_ item: ItemForSale) -> some View {
        HStack(spacing: 15) {
            MediaView(item: item)
                .frame(width: 50, height: 50)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 5) {
                Text(item.name).font(.headline)
                Text("$\(item.price, specifier: "%.2f")").font(.subheadline)
            }
        }
    }

    private func mediaViewSheet() -> some View {
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

    private func itemDetailsViewSheet() -> some View {
        Group {
            if let selectedItem = selectedItem {
                ItemDetailsView(item: selectedItem)
            }
        }
    }

    private func fetchItemsForSale() {
        guard let userId = Auth.auth().currentUser?.uid else {
            self.itemsForSale.removeAll()
            print("User not logged in")
            return
        }

        let db = Firestore.firestore()
        db.collection("itemsForSale").whereField("userId", isEqualTo: userId).getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching items: \(error)")
                return
            }

            guard let documents = snapshot?.documents else {
                print("No documents found")
                return
            }

            self.itemsForSale = documents.compactMap { document -> ItemForSale? in
                try? document.data(as: ItemForSale.self)
            }
        }
    }
}

struct MediaView: View {
    let item: ItemForSale

    var body: some View {
        Group {
            if item.isVideo {
                Image(systemName: "video.fill") // Keep this for videos
                    .resizable()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            } else {
                AsyncImage(url: URL(string: item.mediaUrl)) { phase in
                    switch phase {
                    case .empty: ProgressView()
                    case .success(let image):
                        image.resizable()
                             .aspectRatio(contentMode: .fill)
                             .frame(width: 50, height: 50)
                             .clipShape(Circle())
                    case .failure:
                        Image(systemName: "photo")
                             .resizable()
                             .frame(width: 50, height: 50)
                             .clipShape(Circle())
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
