//
//  FirebaseModel.swift
//  AGAMI
//
//  Created by taehun on 10/13/24.
//

import SwiftUI
import FirebaseFirestore

struct FirestorePlaylistModel: PlaylistModel, Codable, Identifiable {
    @DocumentID var firestoreDocumentID: String?
    var playlistID: String
    var playlistName: String
    var playlistDescription: String
    var photoURL: String
    var latitude: Double
    var longitude: Double
    var generationTime: Date
    var firestoreSongs: [FirestoreSongModel]

    var songs: [any SongModel] {
        get { firestoreSongs }
        set { firestoreSongs = newValue.compactMap { $0 as? FirestoreSongModel } }
    }

    var id: String { playlistID }

    init(
        playlistID: String = UUID().uuidString,
        playlistName: String = "",
        playlistDescription: String = "",
        photoURL: String = "",
        latitude: Double = 36.0126,
        longitude: Double = 129.3235,
        firestoreSongs: [FirestoreSongModel] = [],
        generationTime: Date = Date()
    ) {
        self.playlistID = playlistID
        self.playlistName = playlistName
        self.playlistDescription = playlistDescription
        self.photoURL = photoURL
        self.latitude = latitude
        self.longitude = longitude
        self.firestoreSongs = firestoreSongs
        self.generationTime = generationTime
    }
}
