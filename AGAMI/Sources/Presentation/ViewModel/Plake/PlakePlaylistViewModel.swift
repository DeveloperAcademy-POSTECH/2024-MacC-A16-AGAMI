//
//  ArchivePlaylistViewModel.swift
//  AGAMI
//
//  Created by 박현수 on 10/15/24.
//

import Foundation
import _PhotosUI_SwiftUI

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
        var isUploadingPhoto: Bool = false
    }

    let id: UUID = .init()

    var playlist: PlaylistModel
    private let firebaseService: FirebaseService = FirebaseService()
    private let musicService: MusicService = MusicService()

    var exportingState: ExportingState = .none
    var presentationState: PlaylistPresentationState = .init()

    var selectedItem: PhotosPickerItem? {
        didSet {
            Task {
                await handleAndUploadPhoto()
            }
        }
    }

    var showDeleteButton: Bool {
        !playlist.photoURL.isEmpty && presentationState.isEditing
    }

    init(playlist: PlaylistModel) {
        self.playlist = playlist
    }

    static func == (lhs: PlakePlaylistViewModel, rhs: PlakePlaylistViewModel) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    func exportPlaylistToAppleMusic() async -> URL? {
        exportingState = .isAppleMusicExporting
        do {
            musicService.clearSongs()
            for song in playlist.songs {
                dump("song")
                let appleMusicSong = try await musicService.searchSongById(songId: song.songID)
                musicService.addSongToSongs(song: appleMusicSong)
            }
            try await musicService.createPlaylist(name: playlist.playlistName, description: playlist.playlistDescription)
        } catch {
            dump("Apple Music 플레이리스트 생성 실패: \(error.localizedDescription)")
        }
        exportingState = .none
        guard let urlString = musicService.getCurrentPlaylistUrl() else {
            return nil
        }
        return URL(string: urlString)
    }

    func exportPlaylistToSpotify(completion: @escaping (Result<URL, Error>) -> Void) {
        exportingState = .isSpotifyExporting
        let musicList = playlist.songs.map { ($0.title, $0.artist) }
        SpotifyService.shared.addPlayList(name: playlist.playlistName,
                                          musicList: musicList,
                                          description: playlist.playlistDescription) { [weak self] playlistUri in
            guard let playlistUri = playlistUri else {
                self?.exportingState = .none
                let error = SpotifyError.invalidURI
                completion(.failure(error))
                return
            }
            guard let playlistURL = URL(string: playlistUri.replacingOccurrences(of: "spotify:playlist:", with: "spotify://playlist/")) else {
                self?.exportingState = .none
                let error = SpotifyError.invalidURL
                completion(.failure(error))
                return
            }
            self?.exportingState = .none
            completion(.success(playlistURL))
        }
    }

    func deletePlaylist() async {
        guard let userID = FirebaseAuthService.currentUID else {
            dump("UID를 가져오는 데 실패했습니다.")
            return
        }
        try? await firebaseService.deletePlaylist(userID: userID, playlistID: playlist.playlistID)
    }

    func getCurrentPlaylistURL() -> URL? {
        guard let url = musicService.getCurrentPlaylistUrl() else { return nil }
        return URL(string: url)
    }

    func deleteMusic(indexSet: IndexSet) {
        playlist.songs.remove(atOffsets: indexSet)
    }

    func moveMusic(from source: IndexSet, to destination: Int) {
        playlist.songs.move(fromOffsets: source, toOffset: destination)
    }

    func formatDateToString(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy. MM. dd."
        return dateFormatter.string(from: date)
    }

    func deletePhotoURL() {
        playlist.photoURL = ""
    }

    func applyChangesToFirestore() async {
        presentationState.isUpdating = true
        guard let userID = FirebaseAuthService.currentUID else {
            return
        }
        let firestoreModel = ModelAdapter.toFirestorePlaylist(from: playlist)
        try? await firebaseService.savePlaylistToFirebase(userID: userID, playlist: firestoreModel)
        presentationState.isUpdating = false
    }

    func handleURL(_ url: URL) {
        if let redirectURL = Bundle.main.object(forInfoDictionaryKey: "REDIRECT_URL") as? String,
           let decodedRedirectURL = redirectURL.removingPercentEncoding,
           url.absoluteString.contains(decodedRedirectURL) {
            exportingState = .none
        }
    }

    func handleAndUploadPhoto() async {
        presentationState.isUploadingPhoto = true
        // TODO: photourl 존재 시 갈아끼우기
        do {
            guard let item = selectedItem,
                  let data = try await item.loadTransferable(type: Data.self),
                  let rawImage = UIImage(data: data),
                  let image = rawImage.cropSquare(),
                  let userID = FirebaseAuthService.currentUID else { return }
            let url = try await firebaseService.uploadImageToFirebase(userID: userID, image: image)
            await MainActor.run { playlist.photoURL = url }
        } catch {
            dump("handleAndUploadPhoto Error: \(error.localizedDescription)")
        }
        presentationState.isUploadingPhoto = false
    }
}

