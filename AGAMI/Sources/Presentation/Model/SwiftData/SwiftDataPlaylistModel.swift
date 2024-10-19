//
//  SwiftDataPlaylistModel.swift
//  AGAMI
//
//  Created by 박현수 on 10/18/24.
//

import Foundation
import SwiftData

@Model
final class SwiftDataPlaylistModel {
    @Attribute(.unique) var playlistID: UUID = UUID()
    var playlistName: String?
    var playlistDescription: String?
    var photoURL: String?
    var latitude: Double?
    var longitude: Double?
    var generationTime: Date = Date()

    @Relationship var songs: [SongModel] = []

    init(
        playlistName: String?,
        playlistDescription: String?,
        photoURL: String?,
        latitude: Double?,
        longitude: Double?
    ) {
        self.playlistName = playlistName
        self.playlistDescription = playlistDescription
        self.photoURL = photoURL
        self.latitude = latitude
        self.longitude = longitude
    }
}
