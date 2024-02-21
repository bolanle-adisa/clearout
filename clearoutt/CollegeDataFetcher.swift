//
//  CollegeDataFetcher.swift
//  clearoutt
//
//  Created by Bolanle Adisa on 1/25/24.
//

import Foundation
import FirebaseFirestore

class CollegeDataFetcher: ObservableObject {
    @Published var colleges: [College] = []

    private var db = Firestore.firestore()

    func fetchColleges() {
        db.collection("colleges").order(by: "name").getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.colleges = querySnapshot!.documents.compactMap { document -> College? in
                    try? document.data(as: College.self)
                }
            }
        }
    }
}
