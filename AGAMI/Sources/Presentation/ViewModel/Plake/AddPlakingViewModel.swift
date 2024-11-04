//
//  AddPlakingViewModel.swift
//  AGAMI
//
//  Created by 박현수 on 11/4/24.
//

import Foundation
import ShazamKit

@Observable
final class AddPlakingViewModel: NSObject {
    private let shazamService = ShazamService()
    private let firebaseService = FirebaseService()

    var playlist: PlaylistModel
    var currentItem: SHMediaItem?
    var shazamStatus: ShazamStatus = .idle

    var showBackButtonAlert: Bool = false

    var diggingList: [SongModel] = []

    private override init() {
        fatalError("부모 클래스의 기본 이니셜라이저를 호출하지 마세요. init(playlist:) 이니셜라이저를 사용하세요.")
    }

    init(playlist: PlaylistModel) {
        self.playlist = playlist
        super.init()
        shazamService.delegate = self
    }

    func startRecognition() {
        shazamStatus = .searching
        shazamService.startRecognition()
    }

    func stopRecognition() {
        shazamService.stopRecognition()
    }

    func searchButtonTapped() {
        currentItem = nil

        if shazamStatus == .searching {
            stopRecognition()
            shazamStatus = .idle
        } else {
            startRecognition()
        }
    }

    func deleteSong(indexSet: IndexSet) {
        diggingList.remove(atOffsets: indexSet)
    }

    func moveSong(from source: IndexSet, to destination: Int) {
        diggingList.move(fromOffsets: source, toOffset: destination)
    }

    func addSongsToFirestore() {
        playlist.songs.append(contentsOf: diggingList)
        guard let userID = FirebaseAuthService.currentUID else { return }
        let firestorePlaylist = ModelAdapter.toFirestorePlaylist(from: playlist)
        Task {
            try? await firebaseService.savePlaylistToFirebase(userID: userID, playlist: firestorePlaylist)
        }
    }
}

extension AddPlakingViewModel: ShazamServiceDelegate {
    func shazamService(_ service: ShazamService, didFind match: SHMatch) {
        guard let mediaItem = match.mediaItems.first else { return }
        stopRecognition()
        currentItem = mediaItem
        shazamStatus = .found

        if let item = currentItem {
            diggingList.append(ModelAdapter.fromSHtoFirestoreSong(item))
        }
    }

    func shazamService(_ service: ShazamService, didNotFindMatchFor signature: SHSignature, error: (any Error)?) {
        shazamStatus = .failed
        stopRecognition()
    }

    func shazamService(_ service: ShazamService, didFailWithError error: any Error) {
        shazamStatus = .failed
        stopRecognition()
    }
}

