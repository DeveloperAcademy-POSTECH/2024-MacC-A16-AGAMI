//
//  ModelAdapter.swift
//  AGAMI
//
//  Created by 박현수 on 10/19/24.
//

import Foundation

struct ModelAdapter {
    static func toSwiftDataPlaylist(from playlistModel: PlaylistModel) -> SwiftDataPlaylistModel {
        return SwiftDataPlaylistModel(from: playlistModel)
    }

    static func toSwiftDataSong(from songModel: SongModel) -> SwiftDataSongModel {
        return SwiftDataSongModel(from: songModel)
    }

    static func toFirestorePlaylist(from playlistModel: PlaylistModel) -> FirestorePlaylistModel {
        return FirestorePlaylistModel(from: playlistModel)
    }

    static func toFirestoreSong(from songModel: SongModel) -> FirestoreSongModel {
        return FirestoreSongModel(from: songModel)
    }
}
