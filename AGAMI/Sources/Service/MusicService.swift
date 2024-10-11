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
    
    func createPlaylist(name: String, description: String) async throws -> Playlist {
        try await requestAuthorization()
        
        let library = MusicLibrary.shared
        let newPlaylist = try await library.createPlaylist(name: name, description: description)
        self.playlist = newPlaylist
        
        return newPlaylist
    }
    
    func getCurrentPlaylistUrl() -> String? {
        return playlist?.url?.absoluteString
    }
    
    func searchAndAddSong(songTitle: String) async throws {
        try await requestAuthorization()
        
        guard let playlist = playlist else {
            throw MusicServiceError.playlistNotFound
        }
        
        var searchRequest = MusicCatalogSearchRequest(term: songTitle, types: [Song.self])
        searchRequest.limit = 1
        
        let searchResponse = try await searchRequest.response()
        guard let song = searchResponse.songs.first else {
            throw MusicServiceError.songNotFound
        }
        
        try await MusicLibrary.shared.add(song, to: playlist)
    }
}

enum MusicAuthorizationError: Error {
    case denied
}

enum MusicServiceError: Error {
    case playlistNotFound
    case songNotFound
}
