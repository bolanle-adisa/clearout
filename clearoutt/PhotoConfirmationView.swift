//
//  PhotoConfirmationView.swift
//  clearoutt
//
//  Created by Bolanle Adisa on 2/6/24.
//

import SwiftUI

struct PhotoConfirmationView: View {
    let image: UIImage
    var onRetake: () -> Void
    var onDone: () -> Void

    var body: some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            HStack {
                Button("Retake") {
                    onRetake()
                }

                Button("Done") {
                    onDone()
                }
            }
        }
        .navigationBarTitle("Review Photo", displayMode: .inline)
        .navigationBarItems(
            leading: Button("Retake", action: onRetake),
            trailing: Button("Done", action: onDone)
        )
        .padding()
    }



    func presentImagePickerOrCameraAgain() {
        // Logic to present the camera or image picker again
        // This might involve toggling `isPresentingCameraView` or similar state variable
    }

}

