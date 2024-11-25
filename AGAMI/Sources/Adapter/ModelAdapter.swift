//
//  ModelAdapter.swift
//  AGAMI
//
//  Created by 박현수 on 10/19/24.
//

import Foundation

import ShazamKit

struct ModelAdapter {
    static func toSwiftDataPlaylist(from playlistModel: PlaylistModel) -> SwiftDataPlaylistModel {
        return SwiftDataPlaylistModel(from: playlistModel)
    }

    static func toSwiftDataSong(from songModel: SongModel) -> SwiftDataSongModel {
        return SwiftDataSongModel(from: songModel)
    }

    static func toFirestorePlaylist(from playlistModel: PlaylistModel) -> FirestorePlaylistModel {
        var firestorePlaylist = FirestorePlaylistModel(from: playlistModel)
        firestorePlaylist.songs.sort { $0.orderIndex ?? 0 > $1.orderIndex ?? 0 }
        return firestorePlaylist
    }

    static func toFirestoreSong(from songModel: SongModel) -> FirestoreSongModel {
        return FirestoreSongModel(from: songModel)
    }
    
    static func fromSHtoSwiftDataSong(_ item: SHMediaItem) -> SwiftDataSongModel {
        var artworkURL: String = ""
        if let url = item.artworkURL {
            artworkURL = url.absoluteString
        }
        
        return SwiftDataSongModel(
            songID: item.appleMusicID ?? "",
            title: item.title ?? "",
            artist: item.artist ?? "",
            albumCoverURL: artworkURL
        )
    }

    static func fromSHtoFirestoreSong(_ item: SHMediaItem) -> FirestoreSongModel {
        var artworkURL: String = ""
        if let url = item.artworkURL {
            artworkURL = url.absoluteString
        }

        return FirestoreSongModel(songID: item.appleMusicID ?? "",
                                  title: item.title ?? "",
                                  artist: item.artist ?? "",
                                  albumCoverURL: artworkURL)
    }
}
