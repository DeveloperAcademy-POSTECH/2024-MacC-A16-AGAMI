//
//  MusicViewModel.swift
//  AGAMI
//
//  Created by Seoyeon Choi on 10/11/24.
//

import SwiftUI

import MusicKit

@Observable
final class MusicViewModel {
    var playlistName: String = ""
    var playlistDescription: String = ""
    var songTitle: String = ""
    var statusMessage: String = ""
    
    private let musicService = MusicService()
    
    func requestAuthrization() {
        Task {
            do {
                try await musicService.requestAuthorization()
                statusMessage = "Authorization granted"
            } catch {
                statusMessage = "Authorization denied: \(error.localizedDescription)"
            }
        }
    }
    
    func createPlaylist() {
        Task {
            do {
                _ = try await musicService.createPlaylist(name: playlistName, description: playlistDescription)
                statusMessage = "플레이리스트 '\(playlistName)' 생성 완료."
            } catch {
                statusMessage = "플레이리스트 생성 오류: \(error.localizedDescription)"
            }
        }
    }
    
    func searchAndAddSong() {
        Task {
            do {
                try await musicService.searchAndAddSong(songTitle: songTitle)
                statusMessage = "'\(songTitle)' 곡이 플레이리스트에 추가되었습니다."
                
                if let playlistUrl = musicService.getCurrentPlaylistUrl() {
                    openPlaylist(playlistUrl: playlistUrl)
                }
            } catch {
                statusMessage = "곡 추가 오류: \(error.localizedDescription)"
            }
        }
    }
    
    private func openPlaylist(playlistUrl: String) {
        guard let url = URL(string: playlistUrl) else { return }
        
        DispatchQueue.main.async {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
