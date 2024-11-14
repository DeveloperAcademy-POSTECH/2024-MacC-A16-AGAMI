//
//  ArchivePlaylistViewModel.swift
//  AGAMI
//
//  Created by 박현수 on 10/15/24.
//

import Foundation
import SwiftUI
import PhotosUI
import ColorThiefSwift

@Observable
final class PlakePlaylistViewModel: Hashable {

    struct PlaylistPresentationState {
        var isEditing: Bool = false
        var isExportDialogPresented: Bool = false
        var isPhotoDialogPresented: Bool = false
        var isShowingDeletePhotoAlert: Bool = false
        var isShowingDeletePlakeAlert: Bool = false
        var isShowingPicker: Bool = false
        var isUpdating: Bool = false
        var isLoading: Bool = false
        var isShowingExportingAppleMusicFailedAlert: Bool = false
        var isShowingExportingSpotifyFailedAlert: Bool = false
        var didOpenSpotifyURL = false // 백그라운드에서 포그라운드로 돌아왔을 때의 확인 변수
    }

    let id: UUID = .init()
    
    var playlist: PlaylistModel
    private var initialPlaylist: PlaylistModel
    private let firebaseService: FirebaseService = FirebaseService()
    private let musicService: MusicService = MusicService()
    
    var exportingState: ExportingState = .none
    var presentationState: PlaylistPresentationState = .init()
    
    var selectedItem: PhotosPickerItem? {
        didSet { Task { await handleAndUploadPhotoFromAlbum() } }
    }
    
    var photoFromCamera: UIImage? {
        didSet { Task { await uploadPhotoFromCamera() } }
    }
    
    var showDeleteButton: Bool {
        !playlist.photoURL.isEmpty && presentationState.isEditing
    }
    
    init(playlist: PlaylistModel, initialPlaylist: PlaylistModel) {
        self.playlist = playlist
        self.initialPlaylist = initialPlaylist
    }
    
    static func == (lhs: PlakePlaylistViewModel, rhs: PlakePlaylistViewModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    func exportPlaylistToAppleMusic() async -> URL? {
        guard await musicService.checkAppleMusicSubscriptionStatus() else {
            self.presentationState.isShowingExportingAppleMusicFailedAlert = true
            return nil
        }

        exportingState = .isAppleMusicExporting
        defer { exportingState = .none }

        do {
            musicService.clearSongs()
            try await addSongsToAppleMusic()
            try await musicService.createPlaylist(name: playlist.playlistName, description: playlist.playlistDescription)
            return URL(string: musicService.getCurrentPlaylistUrl() ?? "")
        } catch {
            dump("Apple Music 플레이리스트 생성 실패: \(error.localizedDescription)")
            return nil
        }
    }

    private func addSongsToAppleMusic() async throws {
        for song in playlist.songs {
            let appleMusicSong = try await musicService.searchSongById(songId: song.songID)
            musicService.addSongToSongs(song: appleMusicSong)
        }
    }

    func exportPlaylistToSpotify(completion: @escaping (Result<URL, Error>) -> Void) {
        exportingState = .isSpotifyExporting
        let musicList = playlist.songs.map { ($0.title, $0.artist) }
        presentationState.didOpenSpotifyURL = true
        SpotifyService.shared.addPlayList(name: playlist.playlistName,
                                          musicList: musicList,
                                          description: playlist.playlistDescription) { [weak self] playlistUri in
            guard let self = self else { return }
            self.exportingState = .none

            if let playlistUri = playlistUri, let playlistURL = URL(string: playlistUri.replacingOccurrences(of: "spotify:playlist:", with: "spotify://playlist/")) {
                completion(.success(playlistURL))
            } else {
                completion(.failure(SpotifyError.invalidURI))
            }
        }
    }

    func deletePlaylist() async {
        guard let userID = FirebaseAuthService.currentUID else { return }
        await deletePhoto(userID: userID)
        try? await firebaseService.deletePlaylist(userID: userID, playlistID: playlist.playlistID)
    }

    func deletePhoto(userID: String) async {
        if !playlist.photoURL.isEmpty {
            let pastURL = playlist.photoURL
            try? await firebaseService.deleteImageInFirebase(userID: userID, photoURL: pastURL)
            deletePhotoURL()
        }
    }

    func deletePhotoURL() {
        playlist.photoURL.removeAll()
    }

    func getCurrentPlaylistURL() -> URL? {
        return URL(string: musicService.getCurrentPlaylistUrl() ?? "")
    }
    
    func deleteMusic(at indexSet: IndexSet) {
        playlist.songs.remove(atOffsets: indexSet)
    }
    
    func moveMusic(from source: IndexSet, to destination: Int) {
        playlist.songs.move(fromOffsets: source, toOffset: destination)
    }
    
    func formatDateToString(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy. MM. dd"
        return dateFormatter.string(from: date)
    }
    
    func applyChangesToFirestore() async {
        presentationState.isUpdating = true
        defer { presentationState.isUpdating = false }
        
        guard let userID = FirebaseAuthService.currentUID else { return }
        let firestoreModel = ModelAdapter.toFirestorePlaylist(from: playlist)

        do {
            try await firebaseService.savePlaylistToFirebase(userID: userID, playlist: firestoreModel)
            refreshPlaylist()
            initialPlaylist = firestoreModel
        } catch {
            dump("Failed to save playlist to Firebase: \(error)")
        }
    }
    
    func handleURL(_ url: URL) {
        if let redirectURL = Bundle.main.object(forInfoDictionaryKey: "REDIRECT_URL") as? String,
           let decodedRedirectURL = redirectURL.removingPercentEncoding,
           url.absoluteString.contains(decodedRedirectURL) {
            exportingState = .none
        }
    }
    
    func setPhotoFromCamera(photo: UIImage) {
        photoFromCamera = photo
    }
    
    func handleAndUploadPhotoFromAlbum() async {
        presentationState.isLoading = true
        defer { presentationState.isLoading = false }

        guard let item = selectedItem,
              let data = try? await item.loadTransferable(type: Data.self),
              let rawImage = UIImage(data: data),
              let image = rawImage.cropSquare(),
              let userID = FirebaseAuthService.currentUID else { return }

        await deletePhoto(userID: userID)

        guard let url = try? await firebaseService.uploadImageToFirebase(userID: userID, image: image) else { return
        }
        await MainActor.run { playlist.photoURL = url }
    }
    
    func uploadPhotoFromCamera() async {
        presentationState.isLoading = true
        defer { presentationState.isLoading = false }
        
        guard let userID = FirebaseAuthService.currentUID,
              let image = photoFromCamera else { return }

        guard let url = try? await firebaseService.uploadImageToFirebase(userID: userID, image: image) else {
            return
        }
        await MainActor.run { playlist.photoURL = url }
    }
    
    func downloadPhotoAndSaveToAlbum() async {
        presentationState.isLoading = true
        defer { presentationState.isLoading = false }
        
        guard let url = URL(string: playlist.photoURL),
              let (data, _) = try? await URLSession.shared.data(from: url),
              let image = UIImage(data: data)
        else { return }

        let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        guard status == .authorized || status == .limited else {
            dump("사진 앨범 접근 권한이 없습니다.")
            return
        }

        await MainActor.run {
            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }
        }
    }
    
    func refreshPlaylist() {
        Task {
            guard let userID = FirebaseAuthService.currentUID,
                  let newPlaylist = await firebaseService.fetchPlaylist(
                    userID: userID,
                    playlistID: playlist.playlistID
                  ) else { return }
            
            await MainActor.run { [weak self] in
                guard let self = self else { return }
                self.playlist = newPlaylist
            }
        }
    }
    
    func resetSpotifyURLState() {
        exportingState = .none
        presentationState.didOpenSpotifyURL = false
    }
    
    func resetPlaylist() {
        playlist = initialPlaylist
    }

    func loadImage(urlString: String) async throws -> UIImage {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let image = UIImage(data: data) else {
            throw URLError(.cannotDecodeContentData)
        }
        return image
    }

    func getColors(dominant: MMCQ.Color, palette: [MMCQ.Color]) -> (String, String) {
        let backgroundColor = UIColor(red: CGFloat(dominant.r) / 255.0,
                                      green: CGFloat(dominant.g) / 255.0,
                                      blue: CGFloat(dominant.b) / 255.0,
                                      alpha: 1.0).toHexString()
        let secondaryColor = palette.count > 1
                             ? UIColor(red: CGFloat(palette[1].r) / 255.0,
                                       green: CGFloat(palette[1].g) / 255.0,
                                       blue: CGFloat(palette[1].b) / 255.0,
                                       alpha: 1.0).toHexString()
                             : backgroundColor
        return (backgroundColor, secondaryColor)
    }

    func getInstagramStoryURL() async -> URL? {
        guard let image = try? await loadImage(urlString: playlist.photoURL),
              let imageData = image.jpegData(compressionQuality: 0.5),
              let instaAppID = Bundle.main.object(forInfoDictionaryKey: "INSTA_APP_ID") as? String,
              let instagramURL = URL(string: "instagram-stories://share?source_application=\(instaAppID)"),
              let dominantColor = ColorThief.getColor(from: image),
              let palette = ColorThief.getPalette(from: image, colorCount: 5)
        else { return nil }

        let (backgroundColor, secondaryColor) = getColors(dominant: dominantColor, palette: palette)

        let pasteboardItems: [String: Any] = [
            "com.instagram.sharedSticker.stickerImage": imageData,
            "com.instagram.sharedSticker.backgroundTopColor": backgroundColor,
            "com.instagram.sharedSticker.backgroundBottomColor": secondaryColor
        ]

        UIPasteboard.general.setItems([pasteboardItems], options: [:])

        if await UIApplication.shared.canOpenURL(instagramURL) {
            return instagramURL
        } else if let appStoreURL = URL(string: "https://apps.apple.com/app/instagram/id389801252") {
            return appStoreURL
        }
        return nil
    }
}
