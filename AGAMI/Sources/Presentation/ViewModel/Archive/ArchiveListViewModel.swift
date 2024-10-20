//
//  ArchiveListViewModel.swift
//  AGAMI
//
//  Created by 박현수 on 10/14/24.
//

import Foundation

@Observable
final class ArchiveListViewModel {
    var playlists: [PlaylistModel] = []
    private var unfilteredPlaylists: [PlaylistModel] = []

    var searchText: String = "" {
        didSet {
            filterPlaylists()
        }
    }

    private let firebaseService = FirebaseService()

    func fetchPlaylists() {
        guard let uid = FirebaseAuthService.currentUID else {
            dump("UID를 가져오는 데 실패했습니다.")
            return
        }
        Task {
            do {
                let playlistModels = try await firebaseService.fetchPlaylistsByUserID(userID: uid)
                await updatePlaylists(sortPlaylistsByDate(playlistModels))
                dump(playlists)
            } catch {
                dump("playlist를 가져오는 데 실패했습니다. \(error.localizedDescription)")
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
}
