//
//  ItemRow.swift
//  clearoutt
//
//  Created by Bolanle Adisa on 2/22/24.
//

import SwiftUI

struct ItemRow: View {
    let item: ItemForSale

    var body: some View {
        HStack(spacing: 15) {
            MediaView(item: item)
                .frame(width: 50, height: 50)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 5) {
                Text(item.name).font(.headline)
                Text("$\(item.price, specifier: "%.2f")").font(.subheadline)
            }
            Spacer() // This pushes everything to the left and allows the row to expand fully
        }
        .frame(maxWidth: .infinity) // Ensure the HStack fills the available width
    }
}
