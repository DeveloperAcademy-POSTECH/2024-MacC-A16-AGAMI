//
//  ArchiveListViewModel.swift
//  AGAMI
//
//  Created by 박현수 on 10/14/24.
//

import Foundation
import AuthenticationServices
import FirebaseFirestore

@Observable
final class PlakeListViewModel {
    private let firebaseService = FirebaseService()
    private let authService = FirebaseAuthService()
    private let musicService = MusicService()
    private let listenerService = FirebaseListenerService()

    var playlists: [PlaylistModel] = []
    private var unfilteredPlaylists: [PlaylistModel] = []

    var searchText: String = "" {
        didSet {
            filterPlaylists()
        }
    }

    var isDialogPresented: Bool = false
    var exportingState: ExportingState = .none
    
    init() {
        fetchPlaylists()
    }

    func fetchPlaylists() {
        guard let uid = FirebaseAuthService.currentUID else {
            dump("UID를 가져오는 데 실패했습니다.")
            return
        }
        Task {
            if let playlistModels = try? await firebaseService.fetchPlaylistsByUserID(userID: uid) {
                await updatePlaylists(sortPlaylistsByDate(playlistModels))
            }
        }
    }

    func clearSearchText() {
        searchText = ""
    }

    func logout() {
        authService.signOut { result in
            switch result {
            case .success:
                UserDefaults.standard.removeObject(forKey: "isSignedIn")
            case .failure(let err):
                dump(err.localizedDescription)
            }
        }
    }

    func deleteAllDataInFirebase() async throws {
        guard let userID = FirebaseAuthService.currentUID else {
            dump("UID를 가져오는 데 실패했습니다.")
            return
        }
        
        do {
            try await firebaseService.deleteAllPhotoInStorage(userID: userID)
            try await firebaseService.deleteAllPlaylists(userID: userID)
        } catch {
            dump("\(error.localizedDescription) while deleting account")
        }
    }
    
    func deleteAccountAndSignOut() async {
        if await authService.deleteAccount() {
            logout()
        } else {
            dump("계정 삭제에 실패했습니다.")
        }
    }

    private func sortPlaylistsByDate(_ playlistModels: [PlaylistModel]) -> [PlaylistModel] {
        playlistModels.sorted { $0.generationTime > $1.generationTime }
    }

    @MainActor
    private func updatePlaylists(_ playlistModels: [PlaylistModel]) {
        unfilteredPlaylists = playlistModels
        filterPlaylists()
    }

    private func filterPlaylists() {
        if searchText.isEmpty {
            playlists = unfilteredPlaylists
        } else {
            playlists = unfilteredPlaylists.filter { playlist in
                playlist.playlistName.lowercased().contains(searchText.lowercased())
            }
        }
    }

    func deletePhoto(userID: String, photoURL: String) async {
        if !photoURL.isEmpty {
            try? await firebaseService.deleteImageInFirebase(userID: userID, photoURL: photoURL)
        }
    }

    func deletePlaylist(playlistID: String, photoURL: String) {
        guard let userID = FirebaseAuthService.currentUID else {
            dump("UID를 가져오는 데 실패했습니다.")
            return
        }
        Task {
            await deletePhoto(userID: userID, photoURL: photoURL)
            try? await firebaseService.deletePlaylist(userID: userID, playlistID: playlistID)
            fetchPlaylists()
        }
    }

    func exportPlaylistToAppleMusic(playlist: PlaylistModel) async -> URL? {
        exportingState = .isAppleMusicExporting
        defer { exportingState = .none }
        do {
            musicService.clearSongs()
            for song in playlist.songs {
                let appleMusicSong = try await musicService.searchSongById(songId: song.songID)
                musicService.addSongToSongs(song: appleMusicSong)
            }
            try await musicService.createPlaylist(name: playlist.playlistName, description: playlist.playlistDescription)
        } catch {
            dump("Apple Music 플레이리스트 생성 실패: \(error.localizedDescription)")
        }
        guard let urlString = musicService.getCurrentPlaylistUrl() else {
            return nil
        }
        return URL(string: urlString)
    }

    func exportPlaylistToSpotify(playlist: PlaylistModel, completion: @escaping (Result<URL, Error>) -> Void) {
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

    func formatDateToString(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy. MM. dd."
        return dateFormatter.string(from: date)
    }

    func handleURL(_ url: URL) {
        if let redirectURL = Bundle.main.object(forInfoDictionaryKey: "REDIRECT_URL") as? String,
           let decodedRedirectURL = redirectURL.removingPercentEncoding,
           url.absoluteString.contains(decodedRedirectURL) {
            exportingState = .none
        }
    }

    func observePlaylistCnanges() {
        guard let userID = FirebaseAuthService.currentUID else {
            dump("UID를 가져오는 데 실패했습니다.")
            return
        }
        
        dump("observing playlist changes")
        
        listenerService.startListeningPlaylist(userID: userID) { [weak self] changes in
            changes.forEach { diff in
                switch diff.type {
                case .added:
                    dump("added")
                    self?.stopObservingPlaylistChanges()
                    if let playlist = self?.createPlaylist(from: diff.document) {
                        self?.playlists.insert(playlist, at: 0)
                    }
                case .modified:
                    dump("modified")
                    if let updatedPlaylist = self?.createPlaylist(from: diff.document),
                       let index = self?.playlists.firstIndex(where: { $0.playlistID == updatedPlaylist.id }) {
                        self?.playlists[index] = updatedPlaylist
                    }
                case .removed:
                    dump("removed")
                    let removedID = diff.document.documentID
                    if let index = self?.playlists.firstIndex(where: { $0.playlistID == removedID }) {
                        self?.playlists.remove(at: index)
                    }
                }
            }
            self?.stopObservingPlaylistChanges()
        }
    }
    
    func stopObservingPlaylistChanges() {
        listenerService.stopListeningPlaylist()
    }
    
    private func createPlaylist(from document: DocumentSnapshot) -> FirestorePlaylistModel? {
        guard let data = document.data() else { return nil }
        return FirestorePlaylistModel(dictionary: data)
    }
}
