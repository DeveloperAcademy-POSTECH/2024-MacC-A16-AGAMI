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
    }

    private func checkMicrophonePermission() async -> Bool {
        switch AVAudioApplication.shared.recordPermission {
        case .denied:
            return false
        case .granted:
            return true
        case .undetermined:
            return await AVAudioApplication.requestRecordPermission()
        @unknown default:
            return false
        }
    }

    func startRecognition() async {
        let permission = await checkMicrophonePermission()

        if permission {
            self.shazamStatus = .searching
            changeStatusAfter5Seconds()

            do {
                let matched = try await shazamService.startRecognition()
                handleMatchedMediaItem(matched)
            } catch {
                handleShazamError(error)
            }
        } else {
            self.shazamStatus = .idle
        }
    }

    func stopRecognition() {
        shazamService.stopRecognition()
    }

    private func changeStatusAfter5Seconds() {
        Task {
            try? await Task.sleep(for: .seconds(5))
            if self.shazamStatus == .searching {
                await MainActor.run { self.shazamStatus = .moreSearching }
            }
        }
    }

    private func handleMatchedMediaItem(_ matched: SHMatch) {
        guard let mediaItem = matched.mediaItems.first else { return }
        currentItem = mediaItem
        shazamStatus = .idle

        guard let item = currentItem else { return }
        let song = ModelAdapter.fromSHtoFirestoreSong(item)
        if !playlist.songs.contains(where: { $0.songID == song.songID }) {
            HapticService.shared.playLongHaptic()
            playlist.songs.insert(song, at: 0)
        }
    }

    private func handleShazamError(_ error: Error) {
        guard let shazamError = error as? ShazamError else {
            shazamStatus = .idle
            return
        }

        switch shazamError {
        case .isRunning, .cancelled:
            shazamStatus = .idle
        case .didFail, .didNotFindMatch:
            HapticService.shared.playLongHaptic()
            shazamStatus = .failed
        }
    }

    func searchButtonTapped() {
        currentItem = nil

        if shazamStatus == .searching || shazamStatus == .moreSearching {
            stopRecognition()
            shazamStatus = .idle
        } else {
            Task { await startRecognition() }
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
