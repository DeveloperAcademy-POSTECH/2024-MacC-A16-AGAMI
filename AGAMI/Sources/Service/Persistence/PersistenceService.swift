//
//  PersistenceServiceImpl.swift
//  AGAMI
//
//  Created by 박현수 on 10/18/24.
//

import Foundation

import ShazamKit
import SwiftData

final class PersistenceService {
    let modelContainer: ModelContainer
    let modelContext: ModelContext
    
    static let shared: PersistenceService = .init()
    
    private let diggingListOrderKey = "diggingListOrder"
    
    private init() {
        let schema = Schema([SwiftDataPlaylistModel.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            modelContext = ModelContext(modelContainer)
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
    
    func createPlaylist(
        playlistName: String,
        playlistDescription: String,
        photoURL: String,
        latitude: Double,
        longitude: Double,
        streetAddress: String
    ) throws {
        let item = SwiftDataPlaylistModel(
            playlistName: playlistName,
            playlistDescription: playlistDescription,
            photoURL: photoURL,
            latitude: latitude,
            longitude: longitude,
            streetAddress: streetAddress
        )
        modelContext.insert(item)
        try modelContext.save()
    }
    
    func updatePlaylistName(for item: SwiftDataPlaylistModel, to newPlaylistName: String) throws {
        item.playlistName = newPlaylistName
        try modelContext.save()
    }
    
    func updatePlaylistDescription(for item: SwiftDataPlaylistModel, to newPlaylistDescription: String) throws {
        item.playlistDescription = newPlaylistDescription
        try modelContext.save()
    }
    
    func updatePhotoURL(for item: SwiftDataPlaylistModel, to newPhotoURL: String) throws {
        item.photoURL = newPhotoURL
        try modelContext.save()
    }
    
    func updateCoordinates(for item: SwiftDataPlaylistModel, latitude: Double, longitude: Double) throws {
        item.latitude = latitude
        item.longitude = longitude
        try modelContext.save()
    }
    
    func deletePlaylist(item: SwiftDataPlaylistModel) throws {
        modelContext.delete(item)
        try modelContext.save()
    }
    
    func fetchDiggingList() throws -> [SwiftDataSongModel] {
        let fetchDescriptor = FetchDescriptor<SwiftDataSongModel>()
        return try modelContext.fetch(fetchDescriptor)
    }
    
    func saveSongToDiggingList(from mediaItem: SHMediaItem) throws {
        let songModel = ModelAdapter.fromSHtoSwiftDataSong(mediaItem)
        
        modelContext.insert(songModel)
        try modelContext.save()
    }
    
    func deleteSong(item: SwiftDataSongModel) throws {
        modelContext.delete(item)
        try modelContext.save()
    }
    
    func deleteAllSongs() throws {
        let songs = try fetchDiggingList()
        for song in songs {
            modelContext.delete(song)
        }
        try modelContext.save()
    }
    
    func saveDiggingListOrder(_ list: [SongModel]) {
        let ids = list.map { $0.songID }
        UserDefaults.standard.set(ids, forKey: diggingListOrderKey)
    }
    
    func loadDiggingListWithOrder() throws -> [SongModel] {
        let savedOrder = UserDefaults.standard.stringArray(forKey: diggingListOrderKey) ?? []
        let fetchedSongs = try fetchDiggingList()
        
        return savedOrder.compactMap { id in
            fetchedSongs.first { $0.songID == id }
        } + fetchedSongs.filter { !savedOrder.contains($0.songID) }
    }
    
}
