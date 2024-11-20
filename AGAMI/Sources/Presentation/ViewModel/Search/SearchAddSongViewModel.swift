//
//  SearchAddSongViewModel.swift
//  AGAMI
//
//  Created by Seoyeon Choi on 10/16/24.
//

import SwiftUI
import CoreLocation
import PhotosUI

@Observable
final class SearchAddSongViewModel {
    private let firebaseService = FirebaseService()
    let persistenceService = PersistenceService.shared

    var playlist: PlaylistModel {
        didSet { handleChangeOfNameOrDescription(oldValue: oldValue, newValue: playlist) }
    }

    var diggingList: [SongModel] {
        playlist.songs.sorted { $0.orderIndex ?? 0 < $1.orderIndex ?? 0 }
    }

    var cellAddress: String {
        let components = playlist.streetAddress
                                 .split(separator: ",")
                                 .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

        guard let last = components.last, let first = components.first
        else { return "" }

        return "\(last), \(first)"
    }

    var cellDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy. MM. dd"
        return dateFormatter.string(from: Date())
    }

    // 커버 이미지
    var photoUIImage: UIImage?
    var showSheet: Bool = false

    // 커버 이미지 - 앨범에서 가져오기
    var selectedItem: PhotosPickerItem?
    var showPhotoPicker: Bool = false
    
    // 저장 상태 관리
    var isSaving: Bool = false
    
    init(playlist: PlaylistModel) {
        self.playlist = playlist
    }
    
    func loadSavedSongs() {
        playlist = persistenceService.fetchPlaylist()
    }

    func savedPlaylist() async -> Bool {
        isSaving = true
        defer { isSaving = false }

        guard let uploadedPhotoURL = await savePhotoToFirebase(userID: FirebaseAuthService.currentUID ?? "")
        else { return false }
        playlist.photoURL = uploadedPhotoURL

        // Firebase에 플레이리스트 저장
        do {
            try await firebaseService.savePlaylistToFirebase(
                userID: FirebaseAuthService.currentUID ?? "",
                playlist: ModelAdapter.toFirestorePlaylist(from: playlist)
            )
        } catch {
            dump("Failed to create playlist: \(error)")
            return false
        }
        return true
    }

    func clearDiggingList() {
        persistenceService.deleteAllPlaylists()
    }
    
    func savePhotoUIImage(photoUIImage: UIImage) {
        self.photoUIImage = photoUIImage
    }
    
    func savePhotoToFirebase(userID: String) async -> String? {
        guard let image = photoUIImage else { return nil }

        let photoURL = try? await firebaseService.uploadImageToFirebase(userID: userID, image: image)
        return photoURL
    }
    
    func loadImageFromGallery() async {
        if let data = try? await selectedItem?.loadTransferable(type: Data.self) {
            photoUIImage = UIImage(data: data)?.cropSquare()
        }
    }

    private func handleChangeOfNameOrDescription(oldValue: PlaylistModel, newValue: PlaylistModel) {
        if oldValue.playlistName != newValue.playlistName ||
            oldValue.playlistDescription != newValue.playlistDescription {
            persistenceService.updatePlaylist()
        }
    }
}
