//
//  SearchWritingViewModel.swift
//  AGAMI
//
//  Created by Seoyeon Choi on 10/16/24.
//

import Foundation
import UIKit

@Observable
final class SearchWritingViewModel {
    private let persistenceService = PersistenceService.shared
    private let firebaseService = FirebaseService()
    private let locationService = LocationService()
    
    var playlist = SwiftDataPlaylistModel()
    var userTitle: String = ""
    var userDescription: String = ""
    var photoURL: String = ""
    var photoUIIMage: UIImage?
    var diggingList: [SongModel] = []
    var isLoading: Bool = false
    
    init() {
        loadSavedSongs()
    }
    
    func loadSavedSongs() {
        do {
            self.diggingList = try persistenceService.fetchDiggingList()
        } catch {
            print("Failed to load saved songs: \(error)")
        }
    }
    
    func savedPlaylist() async {
        do {
            guard let currentLocation = locationService.getCurrentLocation() else { return }
            let latitude = currentLocation.latitude
            let longitude = currentLocation.longitude
            
            try persistenceService.createPlaylist(playlistName: userTitle,
                                                  playlistDescription: userDescription,
                                                  photoURL: photoURL,
                                                  latitude: 1.0,
                                                  longitude: 1.0,
                                                  streetAddress: "")
            playlist.playlistName = userTitle
            playlist.playlistDescription = userDescription
            playlist.songs = try persistenceService.fetchDiggingList()
            playlist.photoURL = photoURL
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
    
    func savePhotoUrl(photoUrl: String) {
        self.photoURL = photoUrl
    }
    
    func savePhotoUIimage(photoUIImage: UIImage) {
        self.photoUIIMage = photoUIImage
    }
    
    func savePhotoToFirebase(userID: String) async -> String? {
        if let image = photoUIIMage {
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
