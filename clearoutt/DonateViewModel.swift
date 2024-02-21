//
//  DonateViewModel.swift
//  clearoutt
//
//  Created by Bolanle Adisa on 2/19/24.
//

import Foundation
import CoreLocation
import MapKit

class DonateViewModel: ObservableObject {
    @Published var donationCenters: [DonationCenter] = []

    func fetchDonationCenters() {
        // Simulate fetching donation centers. In a real app, you might make a network request here.
        self.donationCenters = [
            DonationCenter(name: "Center 1", address: "123 Main St", operationalHours: "9AM - 5PM", acceptedDonationTypes: "Books, Clothes", coordinate: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)),
            // Add more centers as needed
        ]
    }
}
