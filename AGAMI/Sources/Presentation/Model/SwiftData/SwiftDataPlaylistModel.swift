//
//  SwiftDataPlaylistModel.swift
//  AGAMI
//
//  Created by 박현수 on 10/18/24.
//

import Foundation
import SwiftData

@Model
final class SwiftDataPlaylistModel: PlaylistModel {
    @Attribute(.unique) var playlistID: String = UUID().uuidString
    var playlistName: String
    var playlistDescription: String
    var photoURL: String
    var latitude: Double
    var longitude: Double
    var generationTime: Date = Date()

    @Relationship var swiftDataSongs: [SwiftDataSongModel] = []

    var songs: [any SongModel] {
        get { swiftDataSongs }
        set { swiftDataSongs = newValue.compactMap { $0 as? SwiftDataSongModel } }
    }

    init(
        playlistName: String = "",
        playlistDescription: String = "",
        photoURL: String = "",
        latitude: Double = 0.0,
        longitude: Double = 0.0
    ) {
        self.playlistName = playlistName
        self.playlistDescription = playlistDescription
        self.photoURL = photoURL
        self.latitude = latitude
        self.longitude = longitude
    }
}
