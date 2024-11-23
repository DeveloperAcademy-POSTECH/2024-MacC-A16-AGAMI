//
//  SearchWritingViewModel.swift
//  AGAMI
//
//  Created by Seoyeon Choi on 10/16/24.
//

import SwiftUI
import CoreLocation
import PhotosUI

@Observable
final class SearchWritingViewModel {
    private let firebaseService = FirebaseService()
    private let persistenceService = PersistenceService.shared
    private let locationService = LocationService.shared
    
    var playlist: PlaylistModel {
        didSet { handleChangeOfName(oldValue: oldValue, newValue: playlist) }
    }
    
    var diggingList: [SongModel] {
        playlist.songs.sorted { $0.orderIndex ?? 0 < $1.orderIndex ?? 0 }
    }
    
    var saveButtonEnabled: Bool {
        playlist.latitude != 0.0 && playlist.longitude != 0.0 && !playlist.streetAddress.isEmpty && !playlist.playlistName.isEmpty && !playlist.playlistDescription.isEmpty && !playlist.songs.isEmpty
    }
    
    // 커버 이미지
    var photoUIImage: UIImage? {
        didSet {
            if let image = photoUIImage {
                playlist.photoData = image.pngData()
                persistenceService.updatePlaylist()
            }
        }
    }
    var showPhotoConfirmDialog: Bool = false
    var showDeleteImageAlert: Bool = false
    
    // 커버 이미지 - 앨범에서 가져오기
    var selectedItem: PhotosPickerItem?
    var showPhotoPicker: Bool = false
    
    // 저장 상태 관리
    var isSaving: Bool = false
    
    // 타이틀
    let maximumTitleLength: Int = 15
    
    init() {
        playlist = persistenceService.fetchPlaylist()
        locationService.delegate = self
    }
    
    func createSearchAddSongViewModel() -> SearchAddSongViewModel {
        SearchAddSongViewModel(playlist: playlist)
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
        }
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
    
    func savePhotoToFirebase(userID: String) async -> String? {
        if let photoData = playlist.photoData,
           let image = UIImage(data: photoData) {
            let photoURL = try? await firebaseService.uploadImageToFirebase(userID: userID, image: image)
            return photoURL
        } else {
            return ""
        }
    }
    
    func clearDiggingList() {
        persistenceService.deleteAllPlaylists()
    }
    
    private func handleChangeOfName(oldValue: PlaylistModel, newValue: PlaylistModel) {
        if oldValue.playlistName != newValue.playlistName {
            persistenceService.updatePlaylist()
        }
    }
    
    func savePhotoUIImage(photoUIImage: UIImage) {
        self.photoUIImage = photoUIImage
    }
    
    func loadImageFromGallery() async {
        if let data = try? await selectedItem?.loadTransferable(type: Data.self) {
            photoUIImage = UIImage(data: data)?.cropToFiveByFour()
        }
    }
    
    func resetImage() {
        photoUIImage = nil
        selectedItem = nil
        playlist.photoData = nil
    }
}

extension SearchWritingViewModel: LocationServiceDelegate {
    func locationService(_ service: LocationService, didUpdate location: [CLLocation]) {
        getCurrentLocation()
    }
}
