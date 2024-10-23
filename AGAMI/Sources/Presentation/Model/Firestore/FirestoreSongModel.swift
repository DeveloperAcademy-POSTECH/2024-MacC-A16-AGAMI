//
//  SongModel.swift
//  AGAMI
//
//  Created by taehun on 10/14/24.
//

import SwiftUI
import FirebaseFirestore

struct FirestoreSongModel: SongModel, Codable, Identifiable {
    var id: String { songID }
    var songID: String
    var title: String
    var artist: String
    var albumCoverURL: String

    init(
        songID: String = "",
        title: String = "",
        artist: String = "",
        albumCoverURL: String = ""
    ) {
        self.songID = songID
        self.title = title
        self.artist = artist
        self.albumCoverURL = albumCoverURL
    }

    init(from songModel: SongModel) {
        self.songID = songModel.songID
        self.title = songModel.title
        self.artist = songModel.artist
        self.albumCoverURL = songModel.albumCoverURL
    }
}