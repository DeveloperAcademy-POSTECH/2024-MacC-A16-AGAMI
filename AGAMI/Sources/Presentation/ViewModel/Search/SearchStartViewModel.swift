//
//  SearchStartViewModel.swift
//  AGAMI
//
//  Created by Seoyeon Choi on 10/16/24.
//

import SwiftUI
import CoreLocation

@Observable
final class SearchStartViewModel {
    private let persistenceService = PersistenceService.shared
    private let locationService = LocationService.shared
    
    // 유저 위치
    var currentLatitude: Double?
    var currentLongitude: Double?
    var currentStreetAddress: String?
    var currentLocality: String = ""
    var currentRegion: String = ""
    
    // 플레이크 타이틀
    var placeHolderAddress: String = ""
    var isLoaded: Bool = false
    var userTitle: String = ""

    var playlist: PlaylistModel

    var diggingList: [SongModel] {
        playlist.songs.sorted { $0.orderIndex ?? 0 < $1.orderIndex ?? 0 }
    }

    var showBackButtonAlert: Bool = false
    
    init() {
        playlist = persistenceService.fetchPlaylist()
        locationService.delegate = self
    }
    
    func createSearchWritingViewModel() -> SearchWritingViewModel {
        return SearchWritingViewModel(
            currentLatitude: currentLatitude,
            currentLongitude: currentLongitude,
            currentStreetAddress: currentStreetAddress,
            placeHolderAddress: placeHolderAddress,
            userTitle: userTitle,
            currentLocality: currentLocality,
            currentRegion: currentRegion
        )
    }
    
    func loadSavedSongs() {
        playlist = persistenceService.fetchPlaylist()
    }
    
    func requestCurrentLocation() {
        locationService.requestCurrentLocation()
    }
    
    func getCurrentLocation() {
        guard let currentLocation = locationService.getCurrentLocation() else { return }
        currentLatitude = currentLocation.coordinate.latitude
        currentLongitude = currentLocation.coordinate.longitude
        
        locationService.coordinateToStreetAddress { [weak self] address in
            guard let self = self else { return }
            
            self.currentStreetAddress = address
            self.setPlaceHolderAddress()
            
            if currentLatitude != nil && currentLongitude != nil && currentStreetAddress != nil {
                isLoaded = true
            }
        }
    }
    
    func setPlaceHolderAddress() {
        if let address = locationService.placeHolderAddress {
            if let range = address.range(of: "로") ?? address.range(of: "길") {
                placeHolderAddress = String(address[..<range.upperBound])
                placeHolderAddress += "에서 만난 플레이크"
            } else {
                placeHolderAddress = address
                placeHolderAddress += "에서 만난 플레이크"
            }
            self.currentRegion = address
            
            if let locality = locationService.locality {
                self.currentLocality = locality
            }
        }
    }
    
    func deleteSong(indexSet: IndexSet) {
        for index in indexSet {
            let song = diggingList[index]
            persistenceService.deleteSong(item: song)
        }
        loadSavedSongs()
    }
    
    func moveSong(from source: IndexSet, to destination: Int) {
        persistenceService.moveSong(from: source, to: destination)
        loadSavedSongs()
    }
    
    func clearDiggingList() {
        persistenceService.deletePlaylist()
    }
}

extension SearchStartViewModel: LocationServiceDelegate {
    func locationService(_ service: LocationService, didUpdate location: [CLLocation]) {
        getCurrentLocation()
    }
    
    func locationService(_ service: LocationService, didGetReverseGeocode location: String) {
        self.currentStreetAddress = location
    }
}
