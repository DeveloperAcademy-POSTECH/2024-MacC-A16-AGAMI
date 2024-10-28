//
//  PlaylistModel.swift
//  AGAMI
//
//  Created by 박현수 on 10/19/24.
//
import Foundation

protocol PlaylistModel {
    var playlistID: String { get }
    var playlistName: String { get set }
    var playlistDescription: String { get set }
    var photoURL: String { get set }
    var latitude: Double { get set }
    var longitude: Double { get set }
    var streetAddress: String { get set }
    var generationTime: Date { get set }
    var songs: [SongModel] { get set }
}
