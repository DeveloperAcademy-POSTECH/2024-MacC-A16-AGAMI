//
//  ModelAdapter.swift
//  AGAMI
//
//  Created by 박현수 on 10/19/24.
//

import Foundation

struct ModelAdapter {
    static func toSwiftDataPlaylist(from firestoreModel: FirestorePlaylistModel) -> SwiftDataPlaylistModel {
        return SwiftDataPlaylistModel(from: firestoreModel)
    }

    static func toSwiftDataSong(from firestoreModel: FirestoreSongModel) -> SwiftDataSongModel {
        return SwiftDataSongModel(from: firestoreModel)
    }

    static func toFirestorePlaylist(from swiftDataModel: SwiftDataPlaylistModel) -> FirestorePlaylistModel {
        return FirestorePlaylistModel(from: swiftDataModel)
    }

    static func toFirestoreSong(from swiftDataModel: SwiftDataSongModel) -> FirestoreSongModel {
        return FirestoreSongModel(from: swiftDataModel)
    }
}
