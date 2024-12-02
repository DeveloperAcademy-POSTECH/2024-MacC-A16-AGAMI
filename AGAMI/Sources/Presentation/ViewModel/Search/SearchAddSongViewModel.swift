//
//  SearchAddSongViewModel.swift
//  AGAMI
//
//  Created by Seoyeon Choi on 10/16/24.
//

import SwiftUI
import ShazamKit

@Observable
final class SearchAddSongViewModel {
    private let firebaseService = FirebaseService()
    private let shazamService = ShazamService.shared
    let persistenceService = PersistenceService.shared

    var currentItem: SHMediaItem?
    var shazamStatus: ShazamStatus = .idle
    
    var playlist: PlaylistModel {
        didSet { handleChangeOfNameOrDescription(oldValue: oldValue, newValue: playlist) }
    }

    var diggingList: [SongModel] {
        playlist.songs.sorted { $0.orderIndex ?? 0 < $1.orderIndex ?? 0 }
    }

    var currentSongId: String? {
        currentItem?.appleMusicID
    }
    
    // 저장 상태 관리
    var isSaving: Bool = false
    
    init(playlist: PlaylistModel) {
        self.playlist = playlist
        shazamService.delegate = self
    }
    
    private func checkMicrophonePermission(completion: @escaping (Bool) -> Void) {
        switch AVAudioApplication.shared.recordPermission {
        case .denied:
            completion(false)
        case .granted:
            completion(true)
        case .undetermined:
            AVAudioApplication.requestRecordPermission { granted in
                Task { @MainActor in
                    completion(granted)
                }
            }
        @unknown default:
            completion(false)
        }
    }
    
    func startRecognition() {
        checkMicrophonePermission { [weak self] granted in
            guard let self = self else { return }
            if granted {
                self.shazamStatus = .searching
                self.shazamService.startRecognition()
                
                Task {
                   try await Task.sleep(for: .seconds(5))
                    await MainActor.run {
                        if self.shazamStatus == .searching {
                            self.shazamStatus = .moreSearching
                        }
                    }
                }
            } else {
                self.shazamStatus = .idle
            }
        }
    }
    
    func stopRecognition() {
        shazamService.stopRecognition()
    }
    
    func searchButtonTapped() {
        currentItem = nil
        
        if shazamStatus == .searching || shazamStatus == .moreSearching {
            stopRecognition()
            shazamStatus = .idle
        } else {
            startRecognition()
        }
    }
    
    func loadSavedSongs() {
        playlist = persistenceService.fetchPlaylist()
    }

    func deleteSong(indexSet: IndexSet) {
        for index in indexSet {
            let song = diggingList[index]
            persistenceService.deleteSong(item: song)
        }
        loadSavedSongs()
    }
    
    func moveSong(from source: IndexSet, to destination: Int) {
        persistenceService.moveSong(from: source, to: destination)
        loadSavedSongs()
    }

    private func handleChangeOfNameOrDescription(oldValue: PlaylistModel, newValue: PlaylistModel) {
        if oldValue.playlistName != newValue.playlistName ||
            oldValue.playlistDescription != newValue.playlistDescription {
            persistenceService.updatePlaylist()
        }
    }
    
    func simpleHaptic() {
        HapticService.shared.playSimpleHaptic()
    }
}

extension SearchAddSongViewModel: ShazamServiceDelegate {
    func shazamService(_ service: ShazamService, didFind match: SHMatch) {
        guard let mediaItem = match.mediaItems.first else { return }
        currentItem = mediaItem
        shazamStatus = .idle
        
        if let item = currentItem {
            HapticService.shared.playLongHaptic()
            persistenceService.appendSong(from: item)
        }
    }
    
    func shazamService(_ service: ShazamService, didNotFindMatchFor signature: SHSignature, error: (any Error)?) {
        HapticService.shared.playLongHaptic()
        shazamStatus = .failed
    }
    
    func shazamService(_ service: ShazamService, didFailWithError error: any Error) {
        HapticService.shared.playLongHaptic()
        shazamStatus = .failed
    }
}
