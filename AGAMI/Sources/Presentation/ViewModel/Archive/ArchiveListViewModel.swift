//
//  ArchiveListViewModel.swift
//  AGAMI
//
//  Created by 박현수 on 10/14/24.
//

import Foundation

@Observable
final class ArchiveListViewModel {
    private let firebaseService = FirebaseService()
    private let authService = FirebaseAuthService()
    private let musicService = MusicService()

    var playlists: [PlaylistModel] = []
    private var unfilteredPlaylists: [PlaylistModel] = []

    var searchText: String = "" {
        didSet {
            filterPlaylists()
        }
    }
    var isDialogPresented: Bool = false
    var exportingState: ExportingState = .none

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

    func deletePlaylist(playlistID: String) {
        guard let userID = FirebaseAuthService.currentUID else {
            dump("UID를 가져오는 데 실패했습니다.")
            return
        }
        Task {
            try? await firebaseService.deletePlaylist(userID: userID, playlistID: playlistID)
            fetchPlaylists()
        }
    }

    func exportPlaylistToAppleMusic(playlist: PlaylistModel) async -> URL? {
        exportingState = .isAppleMusicExporting
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
        exportingState = .none
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
        exportingState = .none
    }

    func formatDateToString(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy. MM. dd."
        return dateFormatter.string(from: date)
    }
}

enum SpotifyError: Error {
    case invalidURI
    case invalidURL
}
