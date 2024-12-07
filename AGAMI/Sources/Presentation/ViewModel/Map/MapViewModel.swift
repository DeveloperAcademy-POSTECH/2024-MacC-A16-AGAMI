//
//  MapViewModel.swift
//  AGAMI
//
//  Created by yegang on 10/12/24.
//

import Foundation
import MapKit

@Observable
final class MapViewModel {
    private let locationService = LocationService.shared

    var currentLocationCoordinate2D: CLLocationCoordinate2D?
    let playlists: [PlaylistModel]

    init(playlists: [PlaylistModel]) {
        self.playlists = playlists
        locationService.delegate = self
    }

    func requestCurrentLocation() {
        locationService.requestCurrentLocation()
    }
}

extension MapViewModel: LocationServiceDelegate {
    func locationService(didUpdate location: CLLocation) {
        currentLocationCoordinate2D = location.coordinate
    }
}
