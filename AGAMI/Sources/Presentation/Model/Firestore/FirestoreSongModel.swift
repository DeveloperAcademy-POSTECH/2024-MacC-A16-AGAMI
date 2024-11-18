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
    var orderIndex: Int?

    init(
        songID: String = "",
        title: String = "",
        artist: String = "",
        albumCoverURL: String = "",
        orderIndex: Int? = nil
    ) {
        self.songID = songID
        self.title = title
        self.artist = artist
        self.albumCoverURL = albumCoverURL
        self.orderIndex = orderIndex
    }

    init(from songModel: SongModel) {
        self.songID = songModel.songID
        self.title = songModel.title
        self.artist = songModel.artist
        self.albumCoverURL = songModel.albumCoverURL
        self.orderIndex = songModel.orderIndex
    }

    init?(dictionary: [String: Any]) {
        guard let songID = dictionary["songID"] as? String,
              let title = dictionary["title"] as? String,
              let artist = dictionary["artist"] as? String,
              let albumCoverURL = dictionary["albumCoverURL"] as? String
        else { return nil }

        let orderIndex = dictionary["orderIndex"] as? Int

        self.songID = songID
        self.title = title
        self.artist = artist
        self.albumCoverURL = albumCoverURL
        self.orderIndex = orderIndex
    }
}
