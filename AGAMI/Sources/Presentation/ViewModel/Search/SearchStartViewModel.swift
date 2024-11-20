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

    var playlist: PlaylistModel {
        didSet { handleChangeOfName(oldValue: oldValue, newValue: playlist) }
    }
    var diggingList: [SongModel] {
        playlist.songs.sorted { $0.orderIndex ?? 0 < $1.orderIndex ?? 0 }
    }

    var isLoaded: Bool {
        playlist.latitude != 0.0 && playlist.longitude != 0.0 && !playlist.streetAddress.isEmpty
    }

    var showBackButtonAlert: Bool = false
    
    init() {
        playlist = persistenceService.fetchPlaylist()
        locationService.delegate = self
    }
    
    func initializeView() {
        loadSavedSongs()
        Task {
            await fetchCurrentLocation()
        }
    }
        
    func createSearchWritingViewModel() -> SearchWritingViewModel {
        SearchWritingViewModel(playlist: playlist)
    }
    
    func loadSavedSongs() {
        playlist = persistenceService.fetchPlaylist()
    }
        
    func fetchCurrentLocation() async {
        do {
            let location = try await locationService.requestCurrentLocation()
            playlist.latitude = location.coordinate.latitude
            playlist.longitude = location.coordinate.longitude
        } catch {
            dump("현재 위치를 가져오는 데 실패했습니다: \(error)")
        }
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
            self.setPlaylistName()
        }
    }
    
    func setPlaylistName() {
        if playlist.playlistName.isEmpty {
            let address = playlist.streetAddress

            if let range = address.range(of: "로") ?? address.range(of: "길") {
                playlist.playlistName = String(address[..<range.upperBound])
                playlist.playlistName += "에서 만난 플레이크"
            } else {
                playlist.playlistName = address
                playlist.playlistName += "에서 만난 플레이크"
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
        persistenceService.deleteAllPlaylists()
    }

    private func handleChangeOfName(oldValue: PlaylistModel, newValue: PlaylistModel) {
        if oldValue.playlistName != newValue.playlistName {
            persistenceService.updatePlaylist()
        }
    }
}

extension SearchStartViewModel: LocationServiceDelegate {
    func locationService(_ service: LocationService, didUpdate location: [CLLocation]) {
        getCurrentLocation()
    }
}
