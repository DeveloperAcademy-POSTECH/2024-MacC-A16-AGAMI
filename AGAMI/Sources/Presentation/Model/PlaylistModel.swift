//
//  FirebaseModel.swift
//  AGAMI
//
//  Created by taehun on 10/13/24.
//

import SwiftUI

struct PlaylistModel {
    var id: UUID
    var playlistName: String
    var authorID: UUID
    var mainPhotoURL: String
    var photoURL: [String]
    var latitude: Double
    var longitude: Double
    var musicID: [String]
    var generationTime: Date
    
    init(id: UUID = UUID(), playlistName: String = "", authorID: UUID = UUID(), mainPhotoURL: String = "", photoURL: [String] = [], latitude: Double = 36.0126, longitude: Double = 129.3235, musicID: [String] = [], generationTime: Date = Date()) {
        self.id = id
        self.playlistName = playlistName
        self.authorID = authorID
        self.mainPhotoURL = mainPhotoURL
        self.photoURL = photoURL
        self.latitude = latitude
        self.longitude = longitude
        self.musicID = musicID
        self.generationTime = generationTime
    }
}
