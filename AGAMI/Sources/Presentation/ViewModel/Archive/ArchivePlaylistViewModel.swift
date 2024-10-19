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
    let dummyURL: String = "https://dummyimage.com/400x400/fff/000"

    var playlistTitle: String = "플레이리스트 타이틀"
    var playlistDescription: String = "몽마르트 언덕에선 아코디언 연주자가 부드럽고 감미로운 멜로디를 연주하고 있고, 강변을 걷다 보니 어디선가 자주 들리던 샹송이 바람을 타고 내 귀에 스며들었다."

    var dummyPlaylist: [SongModel] = (0..<10).map { index in FirestoreSongModel(songID: UUID().uuidString, title: "Dummy Song\(index)", artist: "Dummy Artist", albumCoverURL: "https://dummyimage.com/400x400/fff/000") }

    static func == (lhs: ArchivePlaylistViewModel, rhs: ArchivePlaylistViewModel) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    func deleteMusic(indexSet: IndexSet) {
        for index in indexSet {
            dummyPlaylist.remove(at: index)
        }
    }

    func moveMusic(from source: IndexSet, to destination: Int) {
        dummyPlaylist.move(fromOffsets: source, toOffset: destination)
    }
}
