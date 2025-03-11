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
    var photoData: Data?
    var photoURL: String
    var latitude: Double
    var longitude: Double
    var streetAddress: String
    var generationTime: Date
    var firestoreSongs: [FirestoreSongModel]

    var songs: [SongModel] {
        get { firestoreSongs }
        set { firestoreSongs = newValue.map { FirestoreSongModel(from: $0) } }
    }

    var id: String { playlistID }

    enum CodingKeys: String, CodingKey {
        case firestoreDocumentID, playlistID, playlistName, playlistDescription
        case photoURL, latitude, longitude, streetAddress, generationTime, firestoreSongs
    }

    init(
        playlistID: String = UUID().uuidString,
        playlistName: String = "",
        playlistDescription: String = "",
        photoURL: String = "",
        latitude: Double = 36.0135,
        longitude: Double = 129.3262,
        streetAddress: String = "",
        firestoreSongs: [FirestoreSongModel] = [],
        generationTime: Date = Date()
    ) {
        self.playlistID = playlistID
        self.playlistName = playlistName
        self.playlistDescription = playlistDescription
        self.photoURL = photoURL
        self.latitude = latitude
        self.longitude = longitude
        self.streetAddress = streetAddress
        self.firestoreSongs = firestoreSongs
        self.generationTime = generationTime
    }

    init(from playlistModel: PlaylistModel) {
        self.init(
            playlistID: playlistModel.playlistID,
            playlistName: playlistModel.playlistName,
            playlistDescription: playlistModel.playlistDescription,
            photoURL: playlistModel.photoURL,
            latitude: playlistModel.latitude,
            longitude: playlistModel.longitude,
            streetAddress: playlistModel.streetAddress,
            firestoreSongs: playlistModel.songs.map { FirestoreSongModel(from: $0) },
            generationTime: playlistModel.generationTime
        )
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.playlistID = try container.decodeIfPresent(String.self, forKey: .playlistID) ?? UUID().uuidString
        self.playlistName = try container.decodeIfPresent(String.self, forKey: .playlistName) ?? ""
        self.playlistDescription = try container.decodeIfPresent(String.self, forKey: .playlistDescription) ?? ""
        self.photoURL = try container.decodeIfPresent(String.self, forKey: .photoURL) ?? ""
        self.latitude = try container.decodeIfPresent(Double.self, forKey: .latitude) ?? 36.0135
        self.longitude = try container.decodeIfPresent(Double.self, forKey: .longitude) ?? 129.3262
        self.streetAddress = try container.decodeIfPresent(String.self, forKey: .streetAddress) ?? ""
        self.generationTime = try container.decodeIfPresent(Date.self, forKey: .generationTime) ?? Date()
        self.firestoreSongs = try container.decodeIfPresent([FirestoreSongModel].self, forKey: .firestoreSongs) ?? []
    }

    init?(dictionary: [String: Any]) {
        guard
            let playlistID = dictionary["playlistID"] as? String,
            let playlistName = dictionary["playlistName"] as? String,
            let playlistDescription = dictionary["playlistDescription"] as? String,
            let photoURL = dictionary["photoURL"] as? String,
            let latitude = dictionary["latitude"] as? Double,
            let longitude = dictionary["longitude"] as? Double,
            let streetAddress = dictionary["streetAddress"] as? String,
            let generationTime = dictionary["generationTime"] as? Timestamp,
            let firestoreSongsData = dictionary["firestoreSongs"] as? [[String: Any]]
        else { return nil }

        self.playlistID = playlistID
        self.playlistName = playlistName
        self.playlistDescription = playlistDescription
        self.photoURL = photoURL
        self.latitude = latitude
        self.longitude = longitude
        self.streetAddress = streetAddress
        self.generationTime = generationTime.dateValue()
        self.firestoreSongs = firestoreSongsData.compactMap { FirestoreSongModel(dictionary: $0)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(playlistID, forKey: .playlistID)
        try container.encode(playlistName, forKey: .playlistName)
        try container.encode(playlistDescription, forKey: .playlistDescription)
        try container.encode(photoURL, forKey: .photoURL)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
        try container.encode(streetAddress, forKey: .streetAddress)
        try container.encode(generationTime, forKey: .generationTime)
        try container.encode(firestoreSongs, forKey: .firestoreSongs)
    }
}
