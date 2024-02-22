//
//  AddItemView.swift
//  clearoutt
//
//  Created by Bolanle Adisa on 2/5/24.
//

import SwiftUI
import AVFoundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseFirestoreSwift

struct AddItemView: View {
    @Binding var itemsForSale: [ItemForSale]
    @Environment(\.presentationMode) var presentationMode

    @State private var itemName: String = ""
    @State private var itemDescription: String = ""
    @State private var itemPrice: String = ""
    @State private var selectedSize: String = ""
    @State private var isPresentingMediaPicker = false
    @State private var inputImage: UIImage?
    @State private var itemImage: Image?
    @State private var selectedCategory: String = ""
    @State private var showActionSheet = false
    @State private var showingSourcePicker = false
    @State private var videoURL: URL?
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var sellOrRentOption: String = ""
    @State private var selectedColorIndex = 0





    let sizes = ["XS", "S", "M", "L", "XL", "XXL"]
    let categories = ["Women's Clothes", "Men's Clothes", "Women's Shoes", "Men's Shoes", "Electronics", "Dorm Essentials", "Books"]
    let sellOrRentOptions = ["Sell", "Rent"]
    let currencyFormatter = NumberFormatter.currencyFormatter()

    var body: some View {
        NavigationView {
            Form {
                itemImageSection
                itemNameSection
                itemDescriptionSection
                itemPriceSection
                itemSizeSection
                itemColorSection
                categorySection
                if ["Books", "Dorm Essentials", "Electronics"].contains(selectedCategory) {
                                sellOrRentSection
                            }
            }
            .navigationTitle("Add New Item")
            .navigationBarItems(trailing: Button("Done") {
                addNewItem()
            }.disabled(itemName.isEmpty || itemPrice.isEmpty || selectedSize.isEmpty || selectedCategory.isEmpty || (["Books", "Dorm Essentials", "Electronics"].contains(selectedCategory) && sellOrRentOption.isEmpty) || (inputImage == nil && videoURL == nil)))
            .sheet(isPresented: $isPresentingMediaPicker) {
                UniversalMediaPickerView(inputImage: $inputImage, videoURL: $videoURL, completion: handleMediaSelection, sourceType: sourceType)
            }
        }
    }
    
    private func handleMediaSelection() {
        if let selectedImage = inputImage {
            // An image was selected
            itemImage = Image(uiImage: selectedImage)
        } else if let selectedVideoURL = videoURL {
            // A video was selected, generate a thumbnail
            if let thumbnail = generateThumbnail(for: selectedVideoURL) {
                itemImage = Image(uiImage: thumbnail)
            } else {
                // Fallback if thumbnail generation fails
                itemImage = Image(systemName: "video.fill")
            }
        }
    }

    private func generateThumbnail(for url: URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let assetImageGenerator = AVAssetImageGenerator(asset: asset)
        assetImageGenerator.appliesPreferredTrackTransform = true
        
        let timestamp = CMTime(seconds: 1, preferredTimescale: 60)
        
        do {
            let imageRef = try assetImageGenerator.copyCGImage(at: timestamp, actualTime: nil)
            return UIImage(cgImage: imageRef)
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }


    private func addNewItem() {
        guard !itemName.isEmpty, let price = Double(itemPrice), !selectedCategory.isEmpty, !(["Books", "Dorm Essentials", "Electronics"].contains(selectedCategory) && sellOrRentOption.isEmpty) else { return }

        let completion: (Result<URL, Error>) -> Void = { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let url):
                    self.createItemWithMedia(url: url.absoluteString, isVideo: self.videoURL != nil)
                    self.presentationMode.wrappedValue.dismiss()
                case .failure(let error):
                    print("Upload error: \(error.localizedDescription)")
                }
            }
        }

        if let inputImage = self.inputImage {
            FirebaseStorageManager.shared.uploadImageToStorage(inputImage, completion: completion)
        } else if let videoURL = self.videoURL {
            // Adjust as necessary for copying and uploading from the new location
            let fileManager = FileManager.default
            let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let destinationPath = documentsDirectory.appendingPathComponent(videoURL.lastPathComponent)
            
            do {
                if fileManager.fileExists(atPath: destinationPath.path) {
                    try fileManager.removeItem(at: destinationPath)
                }
                try fileManager.copyItem(at: videoURL, to: destinationPath)
                
                // Now upload from the new location
                FirebaseStorageManager.shared.uploadVideoToStorage(destinationPath, completion: completion)
            } catch {
                print("File copy error: \(error.localizedDescription)")
                // Handle the error, possibly calling completion(.failure(error))
            }
        }
    }

    private func createItemWithMedia(url: String, isVideo: Bool) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            return
        }
        
        let selectedColorName = colorChoices[selectedColorIndex].name
            let newItem = ItemForSale(
            name: itemName,
            description: itemDescription,
            price: Double(itemPrice) ?? 0.0,
            size: selectedSize,
            color: selectedColorName,
            mediaUrl: url,
            isVideo: isVideo,
            sellOrRent: sellOrRentOption,
            userId: userId // Add this line
        )
        
        let db = Firestore.firestore()
        db.collection("itemsForSale").addDocument(data: [
            "name": newItem.name,
            "description": newItem.description,
            "price": newItem.price,
            "size": newItem.size,
            "color": newItem.color.description, // You might need a better way to encode color
            "mediaUrl": newItem.mediaUrl,
            "isVideo": newItem.isVideo,
            "sellOrRent": newItem.sellOrRent,
            "userId": newItem.userId, // Ensure this is included
            "timestamp": FieldValue.serverTimestamp()
        ]) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                self.presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    private var itemImageSection: some View {
        Section(header: Text("Item Image")) {
            Button(action: {
                showingSourcePicker = true
            }) {
                ZStack {
                    if let itemImage = itemImage {
                        itemImage
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: 180) // Larger frame for selected image or video placeholder
                    } else {
                        // Smaller representation for the add button
                        HStack {
                            Spacer()
                            Image(systemName: "plus")
                                .font(.system(size: 20)) // Adjusted for smaller representation
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        .padding() // Add padding to match the height of text fields
                        .background(Rectangle().fill(Color.clear)) // Keep clear background
                        .frame(height: 44) // Match the height of text input fields
                    }
                }
            }
        }
        .actionSheet(isPresented: $showingSourcePicker) {
            ActionSheet(title: Text("Select Media"), message: Text("Choose a source"), buttons: [
                .default(Text("Camera")) {
                    self.sourceType = .camera
                    self.isPresentingMediaPicker = true
                },
                .default(Text("Photo Library")) {
                    self.sourceType = .photoLibrary
                    self.isPresentingMediaPicker = true
                },
                .cancel()
            ])
        }
    }

    private var itemNameSection: some View {
            Section(header: Text("Item Name")) {
                TextField("Enter item name", text: $itemName)
            }
        }

        private var itemDescriptionSection: some View {
            Section(header: Text("Description")) {
                TextField("Enter description", text: $itemDescription)
            }
        }

    private var itemPriceSection: some View {
        Section(header: Text("Price")) {
            HStack {
                Text(currencyFormatter.currencySymbol)
                    .foregroundColor(.gray)
                TextField("Enter price", text: $itemPrice)
                    .keyboardType(.decimalPad)
                    .onReceive(itemPrice.publisher.collect()) {
                        self.itemPrice = String($0.prefix(10)).filter { "0123456789.".contains($0) }
                    }
            }
        }
    }

        private var itemSizeSection: some View {
            Section(header: Text("Size")) {
                Picker("Select size", selection: $selectedSize) {
                    ForEach(sizes, id: \.self) { size in
                        Text(size).tag(size)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
        }

    private var itemColorSection: some View {
            Section(header: Text("Color")) {
                Picker("Select color", selection: $selectedColorIndex) {
                    ForEach(colorChoices.indices, id: \.self) { index in
                        HStack {
                            colorChoices[index].color
                                .frame(width: 20, height: 20)
                                .cornerRadius(10)
                            Text(colorChoices[index].name)
                        }
                    }
                }
                .pickerStyle(WheelPickerStyle())
            }
        }


    private var categorySection: some View {
        Section(header: Text("Category")) {
            Picker("Select Category", selection: $selectedCategory) {
                ForEach(categories, id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(MenuPickerStyle()) // Use MenuPickerStyle for compact presentation
        }
    }
    
    private var sellOrRentSection: some View {
        Section(header: Text("Sell or Rent")) {
            Picker("Sell or Rent", selection: $sellOrRentOption) {
                ForEach(sellOrRentOptions, id: \.self) { option in
                    Text(option).tag(option)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }


    private var addItemButtonSection: some View {
        Section {
            Button("Add Item") {
                // Ensure required fields are filled
                guard !itemName.isEmpty, let price = Double(itemPrice), !selectedSize.isEmpty, !selectedCategory.isEmpty else { return }
                
                // Handle image upload if present
                if let inputImage = self.inputImage {
                    FirebaseStorageManager.shared.uploadImageToStorage(inputImage) { result in
                        switch result {
                        case .success(let url):
                            self.createItemWithMedia(url: url.absoluteString, isVideo: false)
                        case .failure(let error):
                            print("Image upload error: \(error.localizedDescription)")
                        }
                    }
                }
                
                // Handle video upload if present
                if let videoURL = self.videoURL {
                    FirebaseStorageManager.shared.uploadVideoToStorage(videoURL) { result in
                        switch result {
                        case .success(let url):
                            self.createItemWithMedia(url: url.absoluteString, isVideo: true)
                        case .failure(let error):
                            print("Video upload error: \(error.localizedDescription)")
                        }
                    }
                }
            }
            .disabled(itemName.isEmpty || itemPrice.isEmpty || selectedSize.isEmpty || selectedCategory.isEmpty || (inputImage == nil && videoURL == nil))
        }
    }

    
func loadImage() {
    guard let inputImage = inputImage else { return }
    itemImage = Image(uiImage: inputImage)
    }
}

extension NumberFormatter {
    static func currencyFormatter() -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = .current // Adjusts currency symbol based on user's local
        return formatter
    }
}

struct ItemForSale: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var description: String
    var price: Double
    var size: String
    var color: String
    var mediaUrl: String
    var isVideo: Bool
    var sellOrRent: String
    var userId: String
    @ServerTimestamp var timestamp: Date?
}


struct CurrencyInputField: View {
    @Binding var value: Double?
    var formatter: NumberFormatter

    var body: some View {
        HStack {
            Text(formatter.currencySymbol)
            TextField("Amount", value: $value, formatter: formatter)
                .keyboardType(.decimalPad)
        }
    }
}

// Preview for AddItemView
struct AddItemView_Previews: PreviewProvider {
    static var previews: some View {
        AddItemView(itemsForSale: .constant([]))
    }
}
