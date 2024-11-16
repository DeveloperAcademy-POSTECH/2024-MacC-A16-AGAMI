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
    var streetAddress: String
    var generationTime: Date

    @Relationship(deleteRule: .cascade) var swiftDataSongs: [SwiftDataSongModel] = []

    var songs: [SongModel] {
        get { swiftDataSongs }
        set { swiftDataSongs = newValue.map { SwiftDataSongModel(from: $0) } }
    }

    init(
        playlistName: String = "",
        playlistDescription: String = "",
        photoURL: String = "",
        latitude: Double = 0.0,
        longitude: Double = 0.0,
        streetAddress: String = "",
        generationTime: Date = Date()
    ) {
        self.playlistName = playlistName
        self.playlistDescription = playlistDescription
        self.photoURL = photoURL
        self.latitude = latitude
        self.longitude = longitude
        self.streetAddress = streetAddress
        self.playlistName = playlistName
        self.generationTime = generationTime
    }

    init(from playlistModel: PlaylistModel) {
        self.playlistID = playlistModel.playlistID
        self.playlistName = playlistModel.playlistName
        self.playlistDescription = playlistModel.playlistDescription
        self.photoURL = playlistModel.photoURL
        self.latitude = playlistModel.latitude
        self.longitude = playlistModel.longitude
        self.streetAddress = playlistModel.streetAddress
        self.generationTime = playlistModel.generationTime
        self.swiftDataSongs = playlistModel.songs.map { SwiftDataSongModel(from: $0) }
    }
}
