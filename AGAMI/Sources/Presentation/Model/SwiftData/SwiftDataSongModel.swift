//
//  SwiftDataSongModel.swift
//  AGAMI
//
//  Created by 박현수 on 10/18/24.
//

import Foundation
import SwiftData

@Model
final class SwiftDataSongModel: SongModel {
    @Attribute(.unique) var songID: String
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
}
