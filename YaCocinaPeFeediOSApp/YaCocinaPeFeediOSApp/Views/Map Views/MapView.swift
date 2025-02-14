//
//  MapView.swift
//  YaCocinaPeFeediOSApp
//
//  Created by Pablo Butron on 14/2/25.
//

import SwiftUI
import MapKit

struct MapView: View {
    let regionName: String
    @StateObject private var viewModel = MapViewModel()
    
    var body: some View {
        Group {
            if let place = viewModel.place {
                Map(initialPosition: .region(viewModel.region)) {
                    Marker("Origin", coordinate: place.coordinate)
                }
            } else {
                VStack {
                    ProgressView()
                    Text("Loading map")
                }
                .onAppear {
                    viewModel.geocodeCountry(country: regionName)
                }
            }
        }
    }
}


#Preview {
    MapView(regionName: "Bolivia")
}
