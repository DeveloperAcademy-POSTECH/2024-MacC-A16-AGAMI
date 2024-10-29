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
    let locationService = LocationService.shared
    
    var currentlatitude: Double?
    var currentlongitude: Double?
    var currentStreetAddress: String?
    var isLoaded: Bool = false
    
    init() {
//        locationService.delegate = self
    }
    
    func requestLocationAuthorization() {
        locationService.requestLocationAuthorization()
    }
    
    func requestCurrentLocation() {
        locationService.requestCurrentLocation()
    }
    
    func getCurrentLocation() {
        guard let currentLocation = locationService.getCurrentLocation() else {
            dump("currentLocation == nil")
            return
        }
        
        currentlatitude = currentLocation.coordinate.latitude
        currentlongitude = currentLocation.coordinate.longitude
        requestCurrentStreetAddress()
    }
    
    func requestCurrentStreetAddress() {
        locationService.coordinateToStreetAddress()
        currentStreetAddress = locationService.streetAddress
    }
}

extension MapViewModel: LocationServiceDelegate {
    func locationService(_ service: LocationService, didGetReverseGeocode location: String) {
        
    }
    
    func locationService(_ service: LocationService, didUpdate location: [CLLocation]) {
        isLoaded = true
    }
}
