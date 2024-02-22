//
//  ItemDetails.swift
//  clearoutt
//
//  Created by Bolanle Adisa on 2/21/24.
//

import Foundation
import FirebaseFirestoreSwift

struct ItemDetails: Codable {
    @DocumentID var id: String?
    var name: String
    var description: String
    var price: Double
    var size: String
    var color: String
    @ServerTimestamp var timestamp: Date?

    init(from dictionary: [String: Any]) {
        self.id = dictionary["id"] as? String ?? UUID().uuidString
        self.name = dictionary["name"] as? String ?? ""
        self.description = dictionary["description"] as? String ?? ""
        self.price = dictionary["price"] as? Double ?? 0.0
        self.size = dictionary["size"] as? String ?? ""
        self.color = dictionary["color"] as? String ?? ""
    }
}
