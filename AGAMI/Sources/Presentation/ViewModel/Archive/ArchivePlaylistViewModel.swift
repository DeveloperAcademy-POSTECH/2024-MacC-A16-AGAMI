//
//  ArchivePlaylistViewModel.swift
//  AGAMI
//
//  Created by 박현수 on 10/15/24.
//

import Foundation

@Observable
final class ArchivePlaylistViewModel: Hashable {
    let id: UUID = .init()

    var playlist: PlaylistModel
    private let firebaseService: FirebaseService = FirebaseService()
    private let musicService: MusicService = MusicService()

    var isExporting: Bool = false
    var isEditing: Bool = false
    var isDialogPresented: Bool = false

    init(playlist: PlaylistModel) {
        self.playlist = playlist
    }

    static func == (lhs: ArchivePlaylistViewModel, rhs: ArchivePlaylistViewModel) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    func exportPlaylistToAppleMusic() {
        Task {
            isExporting = true
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
            isExporting = false
        }
    }

    func deletePlaylist() async {
        guard let userID = FirebaseAuthService.currentUID else {
            dump("UID를 가져오는 데 실패했습니다.")
            return
        }
        try? await firebaseService.deletePlaylist(userID: userID, playlistID: playlist.playlistID)
    }

    func getCurrentPlaylistURL() -> URL? {
        guard let url = musicService.getCurrentPlaylistUrl() else { return nil }
        return URL(string: url)
    }

    func deleteMusic(indexSet: IndexSet) async {
        playlist.songs.remove(atOffsets: indexSet)
        guard let userID = FirebaseAuthService.currentUID else {
            dump("UID를 가져오는 데 실패했습니다.")
            return
        }
        try? await firebaseService.savePlaylistToFirebase(userID: userID, playlist: ModelAdapter.toFirestorePlaylist(from: playlist))
    }

    func moveMusic(from source: IndexSet, to destination: Int) async {
        playlist.songs.move(fromOffsets: source, toOffset: destination)
        guard let userID = FirebaseAuthService.currentUID else {
            dump("UID를 가져오는 데 실패했습니다.")
            return
        }
        try? await firebaseService.savePlaylistToFirebase(userID: userID, playlist: ModelAdapter.toFirestorePlaylist(from: playlist))
    }
    
    func formatDateToString(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy. MM. dd."
        return dateFormatter.string(from: date)
    }
}

