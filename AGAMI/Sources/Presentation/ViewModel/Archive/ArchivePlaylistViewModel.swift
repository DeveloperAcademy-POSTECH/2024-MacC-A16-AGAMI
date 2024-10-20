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

    init(playlist: PlaylistModel) {
        self.playlist = playlist
    }

    static func == (lhs: ArchivePlaylistViewModel, rhs: ArchivePlaylistViewModel) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
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
