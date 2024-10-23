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
    private let musicService: MusicService = MusicService()

    var isExporting: Bool = false

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
                try await musicService.createPlaylist(
                    name: playlist.playlistName,
                    description: playlist.playlistDescription
                )
                for song in playlist.songs {
                    let appleMusicSong = try await musicService.searchSongById(songId: song.songID)
                    try await musicService.addSongToPlaylist(song: appleMusicSong)
                }
            } catch {
                dump("Apple Music 플레이리스트 생성 실패: \(error.localizedDescription)")
            }
            isExporting = false
        }
    }

    func getCurrentPlaylistURL() -> URL? {
        guard let url = musicService.getCurrentPlaylistUrl() else { return nil }
        return URL(string: url)
    }

    func deleteMusic(indexSet: IndexSet) {
        for index in indexSet {
            playlist.songs.remove(at: index)
        }
    }

    func moveMusic(from source: IndexSet, to destination: Int) {
        playlist.songs.move(fromOffsets: source, toOffset: destination)
    }
}

