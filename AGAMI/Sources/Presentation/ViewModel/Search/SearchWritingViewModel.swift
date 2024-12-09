//
//  SearchWritingViewModel.swift
//  AGAMI
//
//  Created by Seoyeon Choi on 10/16/24.
//

import SwiftUI
import PhotosUI
import MusicKit

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
        playlist.latitude != 0.0 && playlist.longitude != 0.0 && !playlist.streetAddress.isEmpty && !playlist.songs.isEmpty && !isPhotoLoading && !playlist.playlistName.isEmpty
    }
    
    // 커버 이미지
    var photoUIImage: UIImage? {
        didSet {
            guard let image = photoUIImage else {
                isPhotoLoading = false
                return
            }
            processPhoto(image: image)
        }
    }
    var showPhotoConfirmDialog: Bool = false
    var showDeleteImageAlert: Bool = false
    var showBackButtonAlert: Bool = false
    var isPhotoLoading: Bool = false
    
    // 커버 이미지 - 앨범에서 가져오기
    var selectedItem: PhotosPickerItem?
    var showPhotoPicker: Bool = false
    
    // 저장 상태 관리
    var isSaving: Bool = false
    
    // 타이틀
    let maximumTitleLength: Int = 15
    
    var showSongDetailView: Bool = false
    var selectedSong: SongModel?
    var detailSong: DetailSong?
    var isDetailViewLoading: Bool = false
    
    init() {
        playlist = persistenceService.fetchPlaylist()
    }
    
    func createSearchAddSongViewModel() -> SearchAddSongViewModel {
        SearchAddSongViewModel(playlist: playlist)
    }
    
    func requestCurrentLocation() async {
        guard let coordinate = try? await locationService.requestCurrentLocation()
        else { return }

        playlist.latitude = coordinate.latitude
        playlist.longitude = coordinate.longitude

        guard let streetAddress = await locationService.coordinateToStreetAddress()
        else { return }

        playlist.streetAddress = streetAddress

        await MainActor.run { persistenceService.updatePlaylist() }
    }
    
    func savedPlaylist() async -> Bool {
        isSaving = true
        defer { isSaving = false }
        
        if playlist.playlistName.isEmpty {
            playlist.playlistName = "오늘의 소록"
        }
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
    
    func processPhoto(image: UIImage) {
        isPhotoLoading = true
        Task(priority: .userInitiated) {
            guard let resizedAndCroppedImage = image.resizedAndCropped(to: CGSize(width: 1280, height: 1024))
            else {
                await MainActor.run { isPhotoLoading = false }
                return
            }

            await MainActor.run {
                self.playlist.photoData = resizedAndCroppedImage.jpegData(compressionQuality: 0.6)
                self.persistenceService.updatePlaylist()
                self.isPhotoLoading = false
            }
        }
    }
    
    func resetImage() {
        photoUIImage = nil
        selectedItem = nil
        playlist.photoData = nil
    }
    
    func simpleHaptic() {
        HapticService.shared.playSimpleHaptic()
    }
    
    func fetchDetailSong() async {
        do {
            isDetailViewLoading = true
            defer { isDetailViewLoading = false }

            let status = await MusicAuthorization.request()
            guard status == .authorized else {
                return
            }
            
            let request = MusicCatalogResourceRequest<Song>(matching: \.id,
                                                            equalTo: MusicItemID(selectedSong?.songID ?? ""))
            let response = try await request.response()
            guard let song = response.items.first else {
                return
            }
            
            var detailSong = DetailSong()
            detailSong.songTItle = selectedSong?.title
            detailSong.artist = selectedSong?.artist
            detailSong.albumCoverURL = selectedSong?.albumCoverURL
            detailSong.albumTitle = song.albumTitle
            detailSong.genres = song.genreNames
            detailSong.releaseDate = song.releaseDate?.formatDate()
            
            self.detailSong = detailSong
        } catch {
            print(error)
        }
    }
    
    func dismissSongDetailView() {
        selectedSong = nil
        detailSong = nil
        showSongDetailView.toggle()
    }
}
