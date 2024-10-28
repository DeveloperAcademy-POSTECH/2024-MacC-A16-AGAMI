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
    var isLoading: Bool = false
    
    // 유저 위치
    var currentlatitude: Double?
    var currentlongitude: Double?
    var currentStreetAddress: String?
    var placeHolderAddress: String = ""
    var isLoaded: Bool = false
    
    init() {
        loadSavedSongs()
        
        if let address = locationService.placeHolderAddress {
            placeHolderAddress = address
        }
    }
    
    func loadSavedSongs() {
        do {
            self.diggingList = try persistenceService.fetchDiggingList()
        } catch {
            print("Failed to load saved songs: \(error)")
        }
    }
    
    func requestCurrentLocation() {
        locationService.requestCurrentLocation()
    }
    
    func requestCurrentStreetAddress() {
        locationService.coordinateToStreetAddress()
        currentStreetAddress = locationService.streetAddress
    }
    
    func getCurrentLocation() {
        guard let currentLocation = locationService.getCurrentLocation() else { return }
        
        currentlatitude = currentLocation.coordinate.latitude
        currentlongitude = currentLocation.coordinate.longitude
        
        requestCurrentStreetAddress()
        
        if currentlatitude != nil && currentlongitude != nil && currentStreetAddress != nil {
            isLoaded = true
        }
    }
    
    func savedPlaylist() async {
        do {
            guard let currentlatitude = self.currentlatitude,
                  let currentlongitude = self.currentlongitude,
                  let currentStreetAddress = self.currentStreetAddress else { return }
            
            userTitle = userTitle == "" ? "\(placeHolderAddress)에서 만난 플레이크" : userTitle
            
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
        } catch {
            print("Failed to create playlist: \(error)")
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
    
    func showProgress() {
        isLoading = true
    }
    
    func hideProgress() {
        isLoading = false
    }
}

extension SearchWritingViewModel: LocationServiceDelegate {
    func locationService(_ service: LocationService, didUpdate location: [CLLocation]) {
        guard locationService.getCurrentLocation() != nil else {
            print("location nil")
            return
        }
    }
}
