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
    
    // 사용자의 애플뮤직 구독상태를 확인하는 함수
    func checkAppleMusicSubscriptionStatus() async -> Bool {
        let authorizationStatus = await MusicAuthorization.request()
        guard authorizationStatus == .authorized else {
            print("Apple Music 접근 권한이 없습니다.")
            return false
        }
        
        do {
            let subscription = try await MusicSubscription.current
            if subscription.canPlayCatalogContent {
                print("사용자는 Apple Music 구독 중입니다.")
                return true
            } else {
                print("사용자는 Apple Music을 구독하지 않았거나 구독이 만료되었습니다.")
                return false
            }
        } catch {
            print("Apple Music 구독 상태 확인 중 오류 발생: \(error.localizedDescription)")
            return false
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
