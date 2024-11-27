//
//  ArchiveListViewModel.swift
//  AGAMI
//
//  Created by 박현수 on 10/14/24.
//

import Foundation
import AuthenticationServices
import FirebaseFirestore

@Observable
final class PlakeListViewModel {
    private let firebaseService = FirebaseService()
    private let musicService = MusicService()

    var isFetching: Bool = false
    var isSearching: Bool = false
    var isSearchBarPresented: Bool = false

    var isShowingNewPlake: Bool {
        playlists.isEmpty && !isFetching
    }

    var searchText: String = "" {
        didSet {
            keyboardHaptic()
        }
    }

    var playlists: [PlaylistModel] = []
    var filteredplaylists: [PlaylistModel] {
        if searchText.isEmpty {
            playlists
        } else {
            playlists.filter {
                $0.playlistName.lowercased().contains(searchText.lowercased())
            }
        }
    }

    var hasNoResult: Bool {
        !searchText.isEmpty && filteredplaylists.isEmpty
    }

    var isUploading: Bool = false

    var itemsCount: Int { playlists.count }
    var songsCount: Int { playlists.reduce(0) { $0 + $1.songs.count } }

    var isDialogPresented: Bool = false
    var exportingState: ExportingState = .none
    
    func fetchPlaylists() {
        isFetching = true
        
        guard let uid = FirebaseAuthService.currentUID else {
            dump("UID를 가져오는 데 실패했습니다.")
            isFetching = false
            return
        }
        
        Task {
            if let playlistModels = try? await firebaseService.fetchPlaylistsByUserID(userID: uid) {
                await updatePlaylists(sortPlaylistsByDate(playlistModels))
            } else {
                dump("플레이리스트 데이터를 가져오는 데 실패했습니다.")
            }
            await MainActor.run { isFetching = false }
        }
    }

    private func sortPlaylistsByDate(_ playlistModels: [PlaylistModel]) -> [PlaylistModel] {
        playlistModels.sorted { $0.generationTime > $1.generationTime }
    }

    @MainActor
    private func updatePlaylists(_ playlistModels: [PlaylistModel]) {
        playlists = playlistModels
    }

    func deletePhoto(userID: String, photoURL: String) async {
        if !photoURL.isEmpty {
            try? await firebaseService.deleteImageInFirebase(userID: userID, photoURL: photoURL)
        }
    }

    func deletePlaylist(playlistID: String, photoURL: String) {
        guard let userID = FirebaseAuthService.currentUID else {
            dump("UID를 가져오는 데 실패했습니다.")
            return
        }
        Task {
            await deletePhoto(userID: userID, photoURL: photoURL)
            try? await firebaseService.deletePlaylist(userID: userID, playlistID: playlistID)
            fetchPlaylists()
        }
    }

    func exportPlaylistToAppleMusic(playlist: PlaylistModel) async -> URL? {
        exportingState = .isAppleMusicExporting
        defer { exportingState = .none }
        do {
            musicService.clearSongs()
            for song in playlist.songs {
                let appleMusicSong = try await musicService.searchSongById(songId: song.songID)
                musicService.addSongToSongs(song: appleMusicSong)
            }
            try await musicService.createPlaylist(name: playlist.playlistName, description: playlist.playlistDescription)
        } catch {
            dump("Apple Music 플레이리스트 생성 실패: \(error.localizedDescription)")
        }
        guard let urlString = musicService.getCurrentPlaylistUrl() else {
            return nil
        }
        return URL(string: urlString)
    }

    func exportPlaylistToSpotify(playlist: PlaylistModel, completion: @escaping (Result<URL, Error>) -> Void) {
        exportingState = .isSpotifyExporting
        let musicList = playlist.songs.map { ($0.title, $0.artist) }
        SpotifyService.shared.addPlayList(name: playlist.playlistName,
                                          musicList: musicList,
                                          description: playlist.playlistDescription) { [weak self] playlistUri in
            guard let playlistUri = playlistUri else {
                self?.exportingState = .none
                let error = SpotifyError.invalidURI
                completion(.failure(error))
                return
            }
            guard let playlistURL = URL(string: playlistUri.replacingOccurrences(of: "spotify:playlist:", with: "spotify://playlist/")) else {
                self?.exportingState = .none
                let error = SpotifyError.invalidURL
                completion(.failure(error))
                return
            }
            self?.exportingState = .none
            completion(.success(playlistURL))
        }
    }

    func formatDateToString(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM월 dd일"
        return dateFormatter.string(from: date)
    }

    func handleURL(_ url: URL) {
        if let redirectURL = Bundle.main.object(forInfoDictionaryKey: "REDIRECT_URL") as? String,
           let decodedRedirectURL = redirectURL.removingPercentEncoding,
           url.absoluteString.contains(decodedRedirectURL) {
            exportingState = .none
        }
    }

    func simpleHaptic() {
        HapticService.shared.playSimpleHaptic()
    }

    func keyboardHaptic() {
        HapticService.shared.playKeyboardHaptic()
    }

    func clearSearchText() {
        searchText.removeAll()
    }
// MARK: - FirebaseListner 코드
//    private let listenerService = FirebaseListenerService()

//    private var isInitialFetchCompleted = false
    
//    func observePlaylistChanges() {
//        guard let userID = FirebaseAuthService.currentUID else {
//            dump("UID를 가져오는 데 실패했습니다.")
//            return
//        }
//
//        dump("observing playlist changes")
//
//        listenerService.startListeningPlaylist(userID: userID) { [weak self] changes in
//            changes.forEach { diff in
//                switch diff.type {
//                case .added:
////                    if !(self?.isInitialFetchCompleted ?? false) {
//                        dump("added")
//                        if let playlist = self?.createPlaylist(from: diff.document) {
//                            self?.playlists.insert(playlist, at: 0)
//                        }
////                    }
//                case .modified:
//                    dump("modified")
//                    if let updatedPlaylist = self?.createPlaylist(from: diff.document),
//                       let index = self?.playlists.firstIndex(where: { $0.playlistID == updatedPlaylist.id }) {
//                        self?.playlists[index] = updatedPlaylist
//                    }
//                case .removed:
//                    dump("removed")
//                    let removedID = diff.document.documentID
//                    if let index = self?.playlists.firstIndex(where: { $0.playlistID == removedID }) {
//                        self?.playlists.remove(at: index)
//                    }
//                }
//            }
////            self?.isInitialFetchCompleted = true
//            self?.stopObservingPlaylistChanges()
//            self?.isUploading = false
//        }
//    }
//
//    func fetchAndSetInitialPlaylists() async throws {
//        guard !isInitialFetchCompleted else {
//            dump("Initial fetch already completed, skipping fetch.")
//            return
//        }
//        
//        guard let userID = FirebaseAuthService.currentUID else {
//            dump("User ID is not available")
//            throw NSError(domain: "UserIDError", code: -1, userInfo: [NSLocalizedDescriptionKey: "User ID is not available"])
//        }
//        
//        let initialSnapshots = try await listenerService.fetchInitialPlaylistSnapshot(userID: userID)
//        
//        for document in initialSnapshots {
//            if let playlist = createPlaylist(from: document) {
//                playlists.append(playlist)
//            }
//        }
//        
//        dump("Initial fetch completed with \(initialSnapshots.count) playlists")
//        isInitialFetchCompleted = true
//    }
//
//    func stopObservingPlaylistChanges() {
//        listenerService.stopListeningPlaylist()
//    }
//    
//    private func createPlaylist(from document: DocumentSnapshot) -> FirestorePlaylistModel? {
//        guard let data = document.data() else { return nil }
//        return FirestorePlaylistModel(dictionary: data)
//    }
}
