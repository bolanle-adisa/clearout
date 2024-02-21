//
//  DonateView.swift
//  clearoutt
//
//  Created by Bolanle Adisa on 1/24/24.
//

import SwiftUI
import MapKit

struct DonateView: View {
    @StateObject private var viewModel = DonateViewModel()
    @State private var selectedCenter: DonationCenter?

    var body: some View {
        NavigationView {
            VStack {
                Text("Nearby Donation Centers")
                    .font(.headline)
                    .padding()

                List(viewModel.donationCenters) { center in
                    VStack(alignment: .leading) {
                        Text(center.name).font(.headline)
                        Text("Address: \(center.address)")
                        Text("Hours: \(center.operationalHours)")
                        Text("Accepts: \(center.acceptedDonationTypes)")
                    }
                    .padding()
                    .onTapGesture {
                        self.selectedCenter = center
                    }
                }
                Spacer()
            }
            .sheet(item: $selectedCenter) { center in
                MapView(center: center)
            }
            .onAppear {
                viewModel.fetchDonationCenters()
            }
        }
    }
}

struct MapView: View {
    var center: DonationCenter

    var body: some View {
        Map(coordinateRegion: .constant(MKCoordinateRegion(center: center.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))), showsUserLocation: true, annotationItems: [center]) { place in
            MapMarker(coordinate: place.coordinate)
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct DonateView_Previews: PreviewProvider {
    static var previews: some View {
        DonateView()
    }
}
