//
//  AddItemView.swift
//  clearoutt
//
//  Created by Bolanle Adisa on 2/5/24.
//

import SwiftUI

struct AddItemView: View {
    @Binding var itemsForSale: [ItemForSale]
    @Environment(\.presentationMode) var presentationMode

    @State private var itemName: String = ""
    @State private var itemDescription: String = ""
    @State private var itemPrice: String = ""
    @State private var selectedSize: String = ""
    @State private var itemColor: Color = .white
    @State private var isPresentingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var itemImage: Image?
    @State private var selectedCategory: String = ""
    @State private var showingConfirmationView = false
    @State private var showActionSheet = false
    @State private var showingSourcePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary


    let sizes = ["XS", "S", "M", "L", "XL", "XXL"]
    let categories = ["Women's Clothes", "Men's Clothes", "Women's Shoes", "Men's Shoes", "Electronics", "Dorm Essentials", "Books"]
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
            }
            .navigationTitle("Add New Item")
            .navigationBarItems(trailing: Button("Done") {
                addNewItem()
            }.disabled(itemName.isEmpty || itemPrice.isEmpty || selectedSize.isEmpty || selectedCategory.isEmpty || inputImage == nil))
            .sheet(isPresented: $isPresentingImagePicker) {
                ImagePickerView(image: $itemImage, inputImage: $inputImage, sourceType: sourceType)
            }
            .fullScreenCover(isPresented: $showingConfirmationView, onDismiss: {
                self.showingConfirmationView = false
            }) {
                if let inputImage = self.inputImage {
                    PhotoConfirmationView(image: inputImage, onRetake: {
                        // Logic to retake the photo or reselect from the gallery
                        self.isPresentingImagePicker = true
                    }, onDone: {
                        // Confirm the selection
                        self.showingConfirmationView = false
                        // Finalize the image selection
                    })
                }
            }
        }
    }

    private func addNewItem() {
        guard !itemName.isEmpty, !itemPrice.isEmpty, !selectedSize.isEmpty, let price = Double(itemPrice), !selectedCategory.isEmpty, inputImage != nil else { return }
        let newItem = ItemForSale(name: itemName, description: itemDescription, price: price, size: selectedSize, color: itemColor, image: inputImage)
        itemsForSale.append(newItem)
        presentationMode.wrappedValue.dismiss()
    }


    private var itemImageSection: some View {
        Section(header: Text("Item Image")) {
            Button(action: {
                self.showingSourcePicker = true
            }) {
                ZStack {
                    if let itemImage = itemImage {
                        itemImage
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: 180) // Larger frame for selected image
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
            ActionSheet(title: Text("Select Image"), message: Text("Choose a source"), buttons: [
                .default(Text("Camera")) {
                    self.sourceType = .camera
                    self.isPresentingImagePicker = true
                },
                .default(Text("Photo Library")) {
                    self.sourceType = .photoLibrary
                    self.isPresentingImagePicker = true
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
                ColorPicker("Select color", selection: $itemColor)
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


    private var addItemButtonSection: some View {
            Section {
                Button("Add Item") {
                    guard !itemName.isEmpty, !selectedSize.isEmpty, let price = Double(itemPrice) else { return }
                    let newItem = ItemForSale(name: itemName, description: itemDescription, price: price, size: selectedSize, color: itemColor, image: inputImage)
                    itemsForSale.append(newItem)
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(itemName.isEmpty || itemPrice.isEmpty || selectedSize.isEmpty)
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

struct ItemForSale: Identifiable {
    let id = UUID()
    var name: String
    var description: String
    var price: Double
    var size: String
    var color: Color
    var image: UIImage?
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
