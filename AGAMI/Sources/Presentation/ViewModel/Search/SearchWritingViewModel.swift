//
//  SearchWritingViewModel.swift
//  AGAMI
//
//  Created by Seoyeon Choi on 10/16/24.
//

import Foundation
import UIKit
import CoreLocation

@Observable
final class SearchWritingViewModel {
    private let persistenceService = PersistenceService.shared
    private let firebaseService = FirebaseService()
    private let locationService = LocationService.shared
    
    // 플레이리스트 정보
    var playlist = SwiftDataPlaylistModel()
    var diggingList: [SongModel] = []
    var userTitle: String = ""
    var userDescription: String = ""
    
    // 커버 이미지
    var photoURL: String = ""
    var photoUIImage: UIImage?
    var currentDate: String = ""
    var currentLocality: String = ""
    var currentRegion: String = ""
    var showSheet: Bool = false
    
    // 유저 위치
    var currentlatitude: Double?
    var currentlongitude: Double?
    var currentStreetAddress: String?
    var placeHolderAddress: String = ""
    var isLoaded: Bool = false
    
    var isSaving: Bool = false
    
    init() {
        loadSavedSongs()
        
        locationService.delegate = self
        setCurrentDate()
    }
    
    func loadSavedSongs() {
        do {
            self.diggingList = try persistenceService.loadDiggingListWithOrder()
        } catch {
            print("Failed to load saved songs: \(error)")
        }
    }
    
    func requestCurrentLocation() {
        dump("viewmodel requestCurrentLocation")
        locationService.requestCurrentLocation()
    }
    
    func getCurrentLocation() {
        guard let currentLocation = locationService.getCurrentLocation() else { return }
        
        currentlatitude = currentLocation.coordinate.latitude
        currentlongitude = currentLocation.coordinate.longitude
        
        locationService.coordinateToStreetAddress { [weak self] address in
            guard let self = self else { return }
            
            self.currentStreetAddress = address
            self.setAddress()
            
            if currentlatitude != nil && currentlongitude != nil && currentStreetAddress != nil {
                isLoaded = true
            }
        }
    }
    
    func savedPlaylist() async -> Bool {
        isSaving = true
        defer { isSaving = false }
        
        do {
            guard let currentlatitude = self.currentlatitude,
                  let currentlongitude = self.currentlongitude,
                  let currentStreetAddress = self.currentStreetAddress else { return false }
            
            userTitle = userTitle == "" ? placeHolderAddress : userTitle
            
            try persistenceService.createPlaylist(playlistName: userTitle,
                                                  playlistDescription: userDescription,
                                                  photoURL: photoURL,
                                                  latitude: currentlatitude,
                                                  longitude: currentlongitude,
                                                  streetAddress: currentStreetAddress)
            playlist.playlistName = userTitle
            playlist.playlistDescription = userDescription
            playlist.songs = try persistenceService.fetchDiggingList()
            playlist.photoURL = photoURL
            playlist.latitude = currentlatitude
            playlist.longitude = currentlongitude
            playlist.streetAddress = currentStreetAddress
            
            await playlist.photoURL = savePhotoToFirebase(userID: FirebaseAuthService.currentUID ?? "") ?? ""
            try await firebaseService.savePlaylistToFirebase(userID: FirebaseAuthService.currentUID ?? "",
                                                             playlist: ModelAdapter.toFirestorePlaylist(from: playlist))
            return true
        } catch {
            print("Failed to create playlist: \(error)")
            return false
        }
    }
    
    func clearDiggingList() {
        do {
            diggingList.removeAll()
            try persistenceService.deleteAllSongs()
        } catch {
            print("Failed to clear songs: \(error)")
        }
    }
    
    func savePhotoUIImage(photoUIImage: UIImage) {
        self.photoUIImage = photoUIImage
    }
    
    func savePhotoToFirebase(userID: String) async -> String? {
        if let image = photoUIImage {
            do {
                photoURL = try await firebaseService.uploadImageToFirebase(userID: userID, image: image)
            } catch {
                print("이미지 저장 실패: \(error.localizedDescription)")
            }
        }
        return photoURL
    }
    
    func setCurrentDate() {
        let today = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        
        self.currentDate = dateFormatter.string(from: today)
    }
    
    func setAddress() {
        if let address = locationService.placeHolderAddress {
            if let range = address.range(of: "로") ?? address.range(of: "길") {
                placeHolderAddress = String(address[..<range.upperBound])
                placeHolderAddress += "에서 만난 플레이크"
            } else {
                placeHolderAddress = address
                placeHolderAddress += "에서 만난 플레이크"
            }
            currentRegion = address
        }
        if let locality = locationService.locality {
            currentLocality = locality
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
                    print("Error deleting song: \(error)")
                }
            } else {
                print("Error: Song is not of type SwiftDataSongModel")
            }
        }
    }
    
    func moveSong(from source: IndexSet, to destination: Int) {
        diggingList.move(fromOffsets: source, toOffset: destination)
        persistenceService.saveDiggingListOrder(diggingList)
    }
}

extension SearchWritingViewModel: LocationServiceDelegate {
    func locationService(_ service: LocationService, didUpdate location: [CLLocation]) {
        dump("delegate didUpdate method called")
        getCurrentLocation()
    }
    
    func locationService(_ service: LocationService, didGetReverseGeocode location: String) {
        dump("delegate Geocode method called")
        self.currentStreetAddress = location
    }
}
