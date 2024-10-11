//
//  MusicViewModel.swift
//  AGAMI
//
//  Created by Seoyeon Choi on 10/11/24.
//

import Foundation

import MusicKit

@Observable
final class MusicViewModel {
    var playlistName: String = ""
    var playlistDescription: String = ""
    var songTitle: String = ""
    var statusMessage: String = ""
    
    @ObservationIgnored private var playlist: Playlist?
    
    func requestAuthorization() async throws {
        let status = MusicAuthorization.currentStatus
        switch status {
        case .authorized:
            break
        case .notDetermined:
            let newStatus = await MusicAuthorization.request()
            if newStatus != .authorized {
                throw MusicAuthorizationError.denied
            }
        default:
            throw MusicAuthorizationError.denied
        }
    }
    
    func createPlaylist() async {
        do {
            try await requestAuthorization()
            
            let library = MusicLibrary.shared
            playlist = try await library.createPlaylist(name: playlistName, description: playlistDescription)
            
            statusMessage = "플레이리스트 '\(playlistName)' 생성 완료."
        } catch {
            statusMessage = "플레이리스트 생성 오류: \(error.localizedDescription)"
        }
    }
    
    func searchAndAddSong() async {
        do {
            try await requestAuthorization()
            
            guard let playlist = playlist else {
                statusMessage = "먼저 플레이리스트를 생성해주세요."
                return
            }
            
            var searchRequest = MusicCatalogSearchRequest(term: songTitle, types: [Song.self])
            
            searchRequest.limit = 1
            let searchResponse = try await searchRequest.response()
            
            if let song = searchResponse.songs.first {
                try await MusicLibrary.shared.add(song, to: playlist)
                statusMessage = "'\(song.title)' 곡이 플레이리스트에 추가되었습니다."
            } else {
                statusMessage = "곡을 찾을 수 없습니다."
            }
        } catch {
            statusMessage = "곡 추가 오류: \(error.localizedDescription)"
        }
    }
}


enum MusicAuthorizationError: Error {
    case denied
}
