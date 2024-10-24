//
//  SearchWritingViewModel.swift
//  AGAMI
//
//  Created by Seoyeon Choi on 10/16/24.
//

import Foundation

@Observable
final class SearchWritingViewModel {
    private let persistenceService = PersistenceService.shared
    private let firebaseService = FirebaseService()
    
    var playlist = SwiftDataPlaylistModel()
    var userTitle: String = ""
    var userDescription: String = ""
    var photoUrl: String = ""
    var diggingList: [SongModel] = []
    
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
            // 경도, 위도 저장 필요
            try persistenceService.createPlaylist(playlistName: userTitle,
                                                  playlistDescription: userDescription,
                                                  photoURL: photoUrl,
                                                  latitude: 1.0,
                                                  longitude: 1.0,
                                                  streetAddress: "")
            playlist.playlistName = userTitle
            playlist.playlistDescription = userDescription
            playlist.songs = try persistenceService.fetchDiggingList()
            playlist.photoURL = photoUrl
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
        self.photoUrl = photoUrl
    }
}
