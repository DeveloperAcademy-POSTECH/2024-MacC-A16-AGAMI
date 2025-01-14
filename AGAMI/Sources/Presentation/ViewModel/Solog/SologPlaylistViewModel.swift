//
//  SologPlaylistViewModel.swift
//  AGAMI
//
//  Created by 박현수 on 10/15/24.
//

import SwiftUI
import PhotosUI

struct PlaylistPresentationState {
    var isEditing: Bool = false
    var isPhotoDialogPresented: Bool = false
    var isShowingDeletePhotoAlert: Bool = false
    var isShowingDeleteSologAlert: Bool = false
    var isShowingPicker: Bool = false
    var isUpdating: Bool = false
    var isLoading: Bool = false
    var isShowingSongDetailView: Bool = false
    var isDetailViewLoading: Bool = false
    var isShowingExportingAppleMusicFailedAlert: Bool = false
    var isShowingExportingSpotifyFailedAlert: Bool = false
    var didOpenSpotifyURL = false // 백그라운드에서 포그라운드로 돌아왔을 때의 확인 변수
    
    var isSaveButtonDisabled: Bool { isUpdating || isLoading }
}

@Observable
final class SologPlaylistViewModel {
    var playlist: PlaylistModel
    var selectedSong: SongModel?
    var detailSong: DetailSong?
    var currentSongId: String?
    var shazamStatus: ShazamStatus = .idle
    
    private var initialPlaylist: PlaylistModel
    
    private let shazamService = ShazamService.shared
    private let firebaseService = FirebaseService()
    private let musicService = MusicService.shared

    var exportingState: ExportingState = .none
    var presentationState: PlaylistPresentationState = .init()
    
    let exportAppleMusicURLString: String = "itms-apps://itunes.apple.com/app/apple-music/id1108187390"
    
    var selectedItem: PhotosPickerItem? {
        didSet { Task { await handleAndUploadPhotoFromAlbum() } }
    }
    
    var photoFromCamera: UIImage? {
        didSet { Task { await uploadPhotoFromCamera() } }
    }
    
    var showDeleteButton: Bool {
        !playlist.photoURL.isEmpty && presentationState.isEditing
    }
    
    init(playlist: PlaylistModel) {
        self.playlist = playlist
        self.initialPlaylist = playlist
    }

    func deletePhotoURL() {
        playlist.photoURL.removeAll()
    }
    
    func deleteSong(at indexSet: IndexSet) {
        playlist.songs.remove(atOffsets: indexSet)
    }
    
    func moveSong(from source: IndexSet, to destination: Int) {
        playlist.songs.move(fromOffsets: source, toOffset: destination)
    }
    
    func formatDateToString(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        return dateFormatter.string(from: date)
    }
    
    func resetSpotifyURLState() {
        exportingState = .none
        presentationState.didOpenSpotifyURL = false
    }
    
    func resetPlaylist() {
        playlist = initialPlaylist
    }
    
    func simpleHaptic() {
        HapticService.shared.playSimpleHaptic()
    }
    
    func fetchAdditionalDetails() async {
        presentationState.isDetailViewLoading = true
        defer { presentationState.isDetailViewLoading = false }

        guard let songID = selectedSong?.songID,
              let song = await musicService.fetchSongInfoByID(songID)
        else { return }

        detailSong = DetailSong(
            songTitle: selectedSong?.title,
            artist: selectedSong?.artist,
            albumCoverURL: selectedSong?.albumCoverURL,
            albumTitle: song.albumTitle,
            genres: song.genreNames,
            releaseDate: song.releaseDate?.formatDate()
        )
    }
    
    func dismissSongDetailView() {
        selectedSong = nil
        detailSong = nil
        presentationState.isShowingSongDetailView.toggle()
    }
}

// Apple Music & Spotify
extension SologPlaylistViewModel {
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

    func exportPlaylistToSpotify() async -> URL? {
        exportingState = .isSpotifyExporting
        defer { exportingState = .none }

        let musicList = playlist.songs.map { ($0.title, $0.artist) }

        guard let uri = await SpotifyService.shared.addPlayList(
            name: playlist.playlistName,
            musicList: musicList,
            description: playlist.playlistDescription
        ) else {
            dump(SpotifyError.invalidURI)
            return nil
        }

        guard let url = URL(string: uri.replacingOccurrences(of: "spotify:playlist:", with: "spotify://playlist/"))
        else {
            dump(SpotifyError.invalidURL)
            return nil
        }

        return url
    }
}

// Shazam
extension SologPlaylistViewModel {
    private func checkMicrophonePermission() async -> Bool {
        switch AVAudioApplication.shared.recordPermission {
        case .denied:
            return false
        case .granted:
            return true
        case .undetermined:
            return await AVAudioApplication.requestRecordPermission()
        @unknown default:
            return false
        }
    }

    func startRecognition() async {
        let permission = await checkMicrophonePermission()

        if permission {
            shazamStatus = .searching
            changeStatusAfter5Seconds()
            await handleMatchedResult()
        } else {
            self.shazamStatus = .idle
        }
    }

    func stopRecognition() {
        shazamService.stopRecognition()
    }

    private func changeStatusAfter5Seconds() {
        Task {
            try? await Task.sleep(for: .seconds(5))
            if self.shazamStatus == .searching {
                await MainActor.run { self.shazamStatus = .moreSearching }
            }
        }
    }

    private func handleMatchedResult() async {
        do {
            let matched = try await shazamService.startRecognition()
            guard let mediaItem = matched.mediaItems.first else { return }
            currentSongId = mediaItem.appleMusicID
            shazamStatus = .idle

            let song = ModelAdapter.fromSHtoFirestoreSong(mediaItem)
            if !playlist.songs.contains(where: { $0.songID == song.songID }) {
                HapticService.shared.playLongHaptic()
                playlist.songs.insert(song, at: 0)
            }
        } catch {
            handleShazamError(error)
        }
    }

    private func handleShazamError(_ error: Error) {
        guard let shazamError = error as? ShazamError else {
            shazamStatus = .idle
            return
        }

        switch shazamError {
        case .isRunning, .cancelled:
            shazamStatus = .idle
        case .didFail, .didNotFindMatch:
            HapticService.shared.playLongHaptic()
            shazamStatus = .failed
        }
    }

    func searchButtonTapped() {
        currentSongId = nil

        if shazamStatus == .searching || shazamStatus == .moreSearching {
            stopRecognition()
            shazamStatus = .idle
        } else {
            Task { await startRecognition() }
        }
    }
}

// Firebase
extension SologPlaylistViewModel {
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
    
    func applyChangesToFirestore() async {
        presentationState.isUpdating = true
        defer { presentationState.isUpdating = false }
        
        guard let userID = FirebaseAuthService.currentUID,
              let firestoreModel = playlist as? FirestorePlaylistModel
        else { return }
        
        do {
            try await firebaseService.savePlaylistToFirebase(userID: userID, playlist: firestoreModel)
            await refreshPlaylist()
            initialPlaylist = firestoreModel
        } catch {
            dump("Failed to save playlist to Firebase: \(error)")
        }
    }

    func refreshPlaylist() async {
        guard let userID = FirebaseAuthService.currentUID,
              let newPlaylist = await firebaseService.fetchPlaylist(
                userID: userID,
                playlistID: playlist.playlistID
              )
        else { return }

        await MainActor.run { playlist = newPlaylist }
    }
}

// Image Handling
extension SologPlaylistViewModel {
    func setPhotoFromCamera(photo: UIImage) {
        photoFromCamera = photo
    }
    
    func handleAndUploadPhotoFromAlbum() async {
        presentationState.isLoading = true
        defer { presentationState.isLoading = false }
        
        guard let item = selectedItem,
              let data = try? await item.loadTransferable(type: Data.self),
              let rawImage = UIImage(data: data),
              let image = rawImage.cropToFiveByFour(),
              let userID = FirebaseAuthService.currentUID else { return }
        
        await deletePhoto(userID: userID)
        
        guard let url = try? await firebaseService.uploadImageToFirebase(userID: userID, image: image)
        else { return }
        playlist.photoURL = url
    }
    
    func uploadPhotoFromCamera() async {
        presentationState.isLoading = true
        defer { presentationState.isLoading = false }
        
        guard let userID = FirebaseAuthService.currentUID,
              let image = photoFromCamera,
              let url = try? await firebaseService.uploadImageToFirebase(userID: userID, image: image)
        else { return }
        
        await MainActor.run { playlist.photoURL = url }
    }
}

// Instagram
extension SologPlaylistViewModel {
    func getInstagramStoryURL() async -> URL? {
        guard let instaAppID = Bundle.main.object(forInfoDictionaryKey: "INSTA_APP_ID") as? String,
              let instagramURL = URL(string: "instagram-stories://share?source_application=\(instaAppID)")
        else { return nil }
        
        let songImages = await getSongImages()
        let backgroundImage = try? await loadBackgroundImage(
            urlString: playlist.photoURL,
            targetSize: .init(width: 1080, height: 1920)
        )
        let stickerImage = InstagramStickerView(playlist: playlist, images: songImages)

        var pasteboardItems: [String: Any] = [:]
        if let stickerImageData = await stickerImage.asUIImage(size: .init(width: 480, height: 800)) {
            pasteboardItems["com.instagram.sharedSticker.stickerImage"] = stickerImageData

            if let backgroundImageData = backgroundImage?.jpegData(compressionQuality: 0.5) {
                pasteboardItems["com.instagram.sharedSticker.backgroundImage"] = backgroundImageData
            }
        }
        
        UIPasteboard.general.setItems([pasteboardItems], options: [:])
        
        if await UIApplication.shared.canOpenURL(instagramURL) {
            return instagramURL
        } else if let appStoreURL = URL(string: "https://apps.apple.com/app/instagram/id389801252") {
            return appStoreURL
        }
        return nil
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
    
    func loadBackgroundImage(urlString: String, targetSize: CGSize) async throws -> UIImage? {
        if let image = try? await loadImage(urlString: urlString),
           let resized = image.resizedAndCropped(to: targetSize),
           let blurred = resized.applyBlur() {
            return blurred
        } else {
            let defaultBackImage = UIImage(resource: .instagramBackGround)
            return defaultBackImage
        }
    }
    
    private func getSongImages() async -> [UIImage] {
        let suffix = playlist.songs.suffix(3)
        var songImages: [UIImage] = []
        for song in suffix {
            if let songImage = try? await loadImage(urlString: song.albumCoverURL) {
                songImages.append(songImage)
            }
        }
        return songImages
    }
}
