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

    // 플레이크 타이틀
    var placeHolderAddress: String = "" {
        didSet {
            playlist.playlistName = placeHolderAddress
            persistenceService.updatePlaylist()
        }
    }

    var isLoaded: Bool {
        playlist.latitude != 0.0 && playlist.longitude != 0.0 && !playlist.streetAddress.isEmpty
    }

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
            currentLatitude: 0.0,
            currentLongitude: 0.0,
            currentStreetAddress: "",
            placeHolderAddress: "",
            userTitle: "",
            currentLocality: "",
            currentRegion: ""
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
        playlist.latitude = currentLocation.coordinate.latitude
        playlist.longitude = currentLocation.coordinate.longitude
        persistenceService.updatePlaylist()
        
        locationService.coordinateToStreetAddress { [weak self] address in
            guard let self = self else { return }
            
            self.playlist.streetAddress = address ?? ""
            persistenceService.updatePlaylist()

            self.setPlaceHolderAddress()
        }
    }
    
    func setPlaceHolderAddress() {
        let address = playlist.streetAddress

        if let range = address.range(of: "로") ?? address.range(of: "길") {
            placeHolderAddress = String(address[..<range.upperBound])
            placeHolderAddress += "에서 만난 플레이크"
        } else {
            placeHolderAddress = address
            placeHolderAddress += "에서 만난 플레이크"
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
}
