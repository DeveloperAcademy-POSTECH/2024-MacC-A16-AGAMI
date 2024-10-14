//
//  MapViewModel.swift
//  AGAMI
//
//  Created by yegang on 10/12/24.
//

import Foundation
import MapKit

struct Place: Identifiable {
    var id: UUID = UUID()
    var location: CLLocationCoordinate2D
}

@Observable
final class MapViewModel {
    private let locationService = LocationService()

    var places: [Place] = [
        Place(location: CLLocationCoordinate2D(latitude: 36.114332, longitude: 129.425743)),
        Place(location: CLLocationCoordinate2D(latitude: 36.214332, longitude: 129.525743))
    ]
    
    func requestCurrentLocation() {
        locationService.requestCurrentLocation()
    }
    
    func addCurrentLocation() {
        if let loc = locationService.getCurrentLocation() {
            dump(loc)
            let newPlace = Place(location: loc)
            places.append(newPlace)
        } else {
            dump("location nil")
        }
    }
}
