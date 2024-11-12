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
    
    func fetchPlaylists() {
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
    
    func fetchCurrentLocation() async {
            do {
                let location = try await locationService.requestCurrentLocation()
                currentLocationCoordinate2D = location.coordinate
                currentlatitude = location.coordinate.latitude
                currentlongitude = location.coordinate.longitude
                await fetchCurrentStreetAddress()
            } catch {
                dump("현재 위치를 가져오는 데 실패했습니다: \(error)")
            }
        }

        func fetchCurrentStreetAddress() async {
            if let address = await locationService.coordinateToStreetAddress() {
                currentStreetAddress = address
            }
        }
    
    func requestLocationAuthorization() {
        locationService.requestLocationAuthorization()
    }
    
}

extension MapViewModel: LocationServiceDelegate {
    func locationService(_ service: LocationService, didGetReverseGeocode location: String) {
        
    }
    
    func locationService(_ service: LocationService, didUpdate location: [CLLocation]) {
        isLoaded = true
    }
}
