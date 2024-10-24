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
    var isExporting: Bool = false

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
        isExporting = true
        do {
            try await musicService.createPlaylist(
                name: playlist.playlistName,
                description: playlist.playlistDescription
            )
            for song in playlist.songs {
                let appleMusicSong = try await musicService.searchSongById(songId: song.songID)
                try await musicService.addSongToPlaylist(song: appleMusicSong)
            }
        } catch {
            dump("Apple Music 플레이리스트 생성 실패: \(error.localizedDescription)")
        }
        isExporting = false
        guard let urlString = musicService.getCurrentPlaylistUrl() else {
            return nil
        }
        return URL(string: urlString)
    }
}
