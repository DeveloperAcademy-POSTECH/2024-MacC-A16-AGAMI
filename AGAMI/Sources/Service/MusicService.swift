//
//  MusicService.swift
//  AGAMI
//
//  Created by Seoyeon Choi on 10/11/24.
//

import Foundation

import MusicKit

final class MusicService {
    private var playlist: Playlist?
    private var songs: [Song] = []

    func requestAuthorization() async throws {
        let status = MusicAuthorization.currentStatus
        switch status {
        case .authorized:
            return
        case .notDetermined:
            let newStatus = await MusicAuthorization.request()
            if newStatus != .authorized {
                throw MusicAuthorizationError.denied
            }
        default:
            throw MusicAuthorizationError.denied
        }
    }

    func createPlaylist(name: String, description: String) async throws {
        try await requestAuthorization()
        self.playlist = try await MusicLibrary.shared.createPlaylist(name: name, description: description, items: self.songs)
    }

    func getCurrentPlaylistUrl() -> String? {
        return playlist?.url?.absoluteString
    }
    
    func searchSongByTitle(songTitle: String) async throws -> Song {
        try await requestAuthorization()

        var searchRequest = MusicCatalogSearchRequest(term: songTitle, types: [Song.self])
        searchRequest.limit = 1

        let searchResponse = try await searchRequest.response()

        guard let song = searchResponse.songs.first else {
            throw MusicServiceError.songNotFound
        }
        
        return song
    }

    func searchSongById(songId: String) async throws -> Song {
        try await requestAuthorization()

        let resourceRequest = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: MusicItemID(songId))
        let searchResponse = try await resourceRequest.response()

        guard let song = searchResponse.items.first else {
            throw MusicServiceError.songNotFound
        }
        
        return song
    }

    func addSongToSongs(song: Song) {
        songs.append(song)
    }

    func clearSongs() {
        songs.removeAll()
    }
}

enum MusicAuthorizationError: Error {
    case denied
}

enum MusicServiceError: Error {
    case playlistNotFound
    case songNotFound
}

