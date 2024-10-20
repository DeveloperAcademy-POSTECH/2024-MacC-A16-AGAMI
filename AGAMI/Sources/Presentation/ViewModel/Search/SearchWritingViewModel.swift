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
            // 이미지 url, 경도, 위도 저장 필요
            try persistenceService.createPlaylist(playlistName: userTitle,
                                                  playlistDescription: userDescription,
                                                  photoURL: "",
                                                  latitude: 1.0,
                                                  longitude: 1.0)
            playlist.playlistName = userTitle
            playlist.playlistDescription = userDescription
            playlist.songs = try persistenceService.fetchDiggingList()
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
}
