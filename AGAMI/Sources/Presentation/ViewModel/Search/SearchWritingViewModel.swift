//
//  SearchWritingViewModel.swift
//  AGAMI
//
//  Created by Seoyeon Choi on 10/16/24.
//

import SwiftUI
import CoreLocation

@Observable
final class SearchWritingViewModel {
    private let persistenceService = PersistenceService.shared

    var playlist: PlaylistModel {
        didSet { handleChangeOfName(oldValue: oldValue, newValue: playlist) }
    }
    
    var diggingList: [SongModel] {
        playlist.songs.sorted { $0.orderIndex ?? 0 < $1.orderIndex ?? 0 }
    }
    
    var saveButtonEnabled: Bool {
        !playlist.playlistName.isEmpty && !playlist.playlistDescription.isEmpty
    }
    
    // 커버 이미지
    var photoUIImage: UIImage?
    
    init() {
        playlist = persistenceService.fetchPlaylist()
    }
    
    func createSearchAddSongViewModel() -> SearchAddSongViewModel {
        SearchAddSongViewModel(playlist: playlist)
    }
    
    func loadSavedSongs() {
        playlist = persistenceService.fetchPlaylist()
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
    
    func loadImageFromGallery() async {
        if let data = try? await selectedItem?.loadTransferable(type: Data.self) {
            photoUIImage = UIImage(data: data)?.cropToFiveByFour()
        }
    }

    private func handleChangeOfName(oldValue: PlaylistModel, newValue: PlaylistModel) {
        if oldValue.playlistName != newValue.playlistName {
            persistenceService.updatePlaylist()
        }
    }
    
    func savePhotoUIImage(photoUIImage: UIImage) {
        self.photoUIImage = photoUIImage
    }
}
