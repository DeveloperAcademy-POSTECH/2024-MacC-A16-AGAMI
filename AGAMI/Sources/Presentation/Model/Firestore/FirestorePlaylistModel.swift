//
//  FirebaseModel.swift
//  AGAMI
//
//  Created by taehun on 10/13/24.
//

import Foundation
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

    var songs: [SongModel] {
        get { firestoreSongs }
        set { firestoreSongs = newValue.map { FirestoreSongModel(from: $0) } }
    }

    var id: String { playlistID }

    init(
        playlistID: String = UUID().uuidString,
        playlistName: String = "",
        playlistDescription: String = "",
        photoURL: String = "",
        latitude: Double = 36.0135,
        longitude: Double = 129.3262,
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

    init(from playlistModel: PlaylistModel) {
        self.playlistID = playlistModel.playlistID
        self.playlistName = playlistModel.playlistName
        self.playlistDescription = playlistModel.playlistDescription
        self.photoURL = playlistModel.photoURL
        self.latitude = playlistModel.latitude
        self.longitude = playlistModel.longitude
        self.generationTime = playlistModel.generationTime
        self.firestoreSongs = playlistModel.songs.map { FirestoreSongModel(from: $0) }
    }
}
