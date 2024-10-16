//
//  FirebaseModel.swift
//  AGAMI
//
//  Created by taehun on 10/13/24.
//

import SwiftUI
import FirebaseFirestore

struct Playlist: Codable, Identifiable {
    @DocumentID var id: String?
    var playlistID: UUID
    var playlistName: String
    var description: String
    var photoURL: String
    var songs: [Song]
    var latitude: Double
    var longitude: Double
    var generationTime: Date
    
    init(
        playlistID: UUID = UUID(),
        playlistName: String = "",
        description: String = "",
        photoURL: String = "",
        latitude: Double = 36.0126,
        longitude: Double = 129.3235,
        songs: [Song] = [],
        generationTime: Date = Date()
    ) {
        self.playlistID = playlistID
        self.playlistName = playlistName
        self.description = description
        self.photoURL = photoURL
        self.latitude = latitude
        self.longitude = longitude
        self.songs = songs
        self.generationTime = generationTime
    }
}
