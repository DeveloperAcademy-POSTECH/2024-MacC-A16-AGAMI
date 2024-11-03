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
    var currentLocality: String?
    var currentRegion: String?
    
    // 플레이크 타이틀
    var placeHolderAddress: String = ""
    var isLoaded: Bool = false
    var userTitle: String = ""
    
    // 수집한 노래
    var diggingList: [SongModel] = []
    
    var showBackButtonAlert: Bool = false
    
    init() {
        loadSavedSongs()
        locationService.delegate = self
    }
    
    func loadSavedSongs() {
        do {
            self.diggingList = try persistenceService.loadDiggingListWithOrder()
        } catch {
            dump("Failed to load saved songs: \(error)")
        }
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
            let songToDelete = diggingList[index]
            diggingList.remove(at: index)
            
            if let song = songToDelete as? SwiftDataSongModel {
                do {
                    try persistenceService.deleteSong(item: song)
                    loadSavedSongs()
                } catch {
                    dump("Error deleting song: \(error)")
                }
            } else {
                dump("Error: Song is not of type SwiftDataSongModel")
            }
        }
    }
    
    func moveSong(from source: IndexSet, to destination: Int) {
        diggingList.move(fromOffsets: source, toOffset: destination)
        persistenceService.saveDiggingListOrder(diggingList)
    }
    
    func clearDiggingList() {
        do {
            diggingList.removeAll()
            try persistenceService.deleteAllSongs()
        } catch {
            print("Failed to clear songs: \(error)")
        }
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
