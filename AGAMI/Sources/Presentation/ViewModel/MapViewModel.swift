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
    private let firebaseService = FirebaseService()
    private let authService = FirebaseAuthService()
    private let locationService = LocationService.shared
    
    var currentLocationCoordinate2D: CLLocationCoordinate2D?
    var currentlatitude: Double?
    var currentlongitude: Double?
    var currentStreetAddress: String?
    var isLoaded: Bool = false

    var goToDetail: Bool = false

    var playlists: [PlaylistModel] = []
    
    func fecthPlaylists() {
        guard let uid = FirebaseAuthService.currentUID else {
            dump("UID를 가져오는데 실패했습니다.")
            return
        }
        
        Task {
            if let playlistModels = try? await firebaseService.fetchPlaylistsByUserID(userID: uid) {
                playlists = playlistModels
            }
        }
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
        
        currentLocationCoordinate2D = currentLocation.coordinate
        currentlatitude = currentLocation.coordinate.latitude
        currentlongitude = currentLocation.coordinate.longitude
        requestCurrentStreetAddress()
    }
    
    func requestCurrentStreetAddress() {
        locationService.coordinateToStreetAddress { _ in }
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
