//
//  ImageViewer.swift
//  clearoutt
//
//  Created by Bolanle Adisa on 2/19/24.
//

import SwiftUI

struct ImageViewer: View {
    let urlString: String

    var body: some View {
        if let url = URL(string: urlString) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image.resizable().scaledToFit()
                case .failure:
                    Image(systemName: "photo").imageScale(.large)
                @unknown default:
                    EmptyView()
                }
            }
        }
    }
}
