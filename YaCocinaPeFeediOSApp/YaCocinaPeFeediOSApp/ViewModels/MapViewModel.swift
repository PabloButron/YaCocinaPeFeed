//
//  MapViewModel.swift
//  YaCocinaPeFeediOSApp
//
//  Created by Pablo Butron on 14/2/25.
//


import Foundation
import MapKit

struct Place: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let title: String?
}

class MapViewModel: ObservableObject {
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 20.0, longitude: 0.0),
        span: MKCoordinateSpan(latitudeDelta: 40, longitudeDelta: 40)
    )
    @Published var place: Place?
    
    private let geocoder = CLGeocoder()
    
    func geocodeCountry(country: String) {
        geocoder.geocodeAddressString(country) { [weak self] placemarks, error in
            if let error = error {
                print("Error during geocoding: \(error.localizedDescription)")
                return
            }
            guard let placemark = placemarks?.first,
                  let location = placemark.location else {
                print("Ubication not found \(country)")
                return
            }
            
            let coordinate = location.coordinate
            DispatchQueue.main.async {
                self?.region = MKCoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
                )
                self?.place = Place(coordinate: coordinate, title: country)
            }
        }
    }
}

