//
//  FirebaseStorageManager.swift
//  clearoutt
//
//  Created by Bolanle Adisa on 2/6/24.
//

import Foundation
import Firebase
import FirebaseStorage
import UIKit

class FirebaseStorageManager {
    
    static let shared = FirebaseStorageManager()
    
    private init() {} // Private initializer for Singleton
    
    func uploadImageToStorage(_ image: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(StorageError.failedToConvertImage))
            return
        }
        
        let storageRef = Storage.storage().reference()
        let imageRef = storageRef.child("images/\(UUID().uuidString).jpg")
        
        let uploadTask = imageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            imageRef.downloadURL { (url, error) in
                if let error = error {
                    completion(.failure(error))
                } else if let downloadURL = url {
                    completion(.success(downloadURL))
                }
            }
        }
        
        uploadTask.observe(.progress) { snapshot in
            if let progress = snapshot.progress {
                print("Upload progress: \(progress.fractionCompleted)")
            }
        }
    }
    
    enum StorageError: Error {
        case failedToConvertImage
    }
}

