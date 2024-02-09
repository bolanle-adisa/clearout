//
//  ImagePickerViiew.swift
//  clearoutt
//
//  Created by Bolanle Adisa on 2/1/24.
//

import SwiftUI

struct ImagePickerView: UIViewControllerRepresentable {
    @Binding var image: Image?
    @Binding var inputImage: UIImage?
    @Binding var videoURL: URL?
    var completion: (() -> Void)?
    var sourceType: UIImagePickerController.SourceType

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        picker.mediaTypes = ["public.image", "public.movie"] // Include both image and movie types
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePickerView

        init(_ parent: ImagePickerView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = Image(uiImage: uiImage)
                parent.inputImage = uiImage
            } else if let videoUrl = info[.mediaURL] as? URL {
                parent.videoURL = videoUrl
            }
            parent.completion?()
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
