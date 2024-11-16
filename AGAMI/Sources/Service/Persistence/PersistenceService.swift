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
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext
    
    private let diggingListOrderKey = "diggingListOrder"

    private var model: SwiftDataPlaylistModel?

    static let shared: PersistenceService = .init()

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

    func getCurrentPlaylist() -> PlaylistModel? {
        guard let model = model else { return nil }
        return model
    }

    func createPlaylist(
        playlistName: String,
        playlistDescription: String,
        photoURL: String,
        latitude: Double,
        longitude: Double,
        streetAddress: String
    ) throws {
        model = SwiftDataPlaylistModel(
            playlistName: playlistName,
            playlistDescription: playlistDescription,
            photoURL: photoURL,
            latitude: latitude,
            longitude: longitude,
            streetAddress: streetAddress
        )
        guard let model = model else { return }
        modelContext.insert(model)
        try modelContext.save()
    }
    
    func updatePlaylistName(to newPlaylistName: String) throws {
        guard let model = model else { return }
        model.playlistName = newPlaylistName
        try modelContext.save()
    }
    
    func updatePlaylistDescription(to newPlaylistDescription: String) throws {
        guard let model = model else { return }
        model.playlistDescription = newPlaylistDescription
        try modelContext.save()
    }
    
    func updatePhotoURL(to newPhotoURL: String) throws {
        guard let model = model else { return }
        model.photoURL = newPhotoURL
        try modelContext.save()
    }
    
    func updateCoordinates(latitude: Double, longitude: Double) throws {
        guard let model = model else { return }
        model.latitude = latitude
        model.longitude = longitude
        try modelContext.save()
    }
    
    func deletePlaylist() throws {
        guard let model = model else { return }
        modelContext.delete(model)
        self.model = nil
        try modelContext.save()
    }
    
    func fetchDiggingList() throws -> [SongModel] {
        let fetchDescriptor = FetchDescriptor<SwiftDataSongModel>()
        return try modelContext.fetch(fetchDescriptor)
    }
    
    func saveSongToDiggingList(from mediaItem: SHMediaItem) throws {
        let songModel = ModelAdapter.fromSHtoSwiftDataSong(mediaItem)
        
        modelContext.insert(songModel)
        try modelContext.save()
    }
    
    func deleteSong(item: SongModel) throws {
        guard let model = model,
              let swiftDataSong = model.swiftDataSongs.first(where: { $0.songID == item.songID })
        else { return }
        modelContext.delete(swiftDataSong)
        try modelContext.save()
    }
    
    func deleteAllSongs() throws {
        guard let model = model else { return }
        model.songs = []
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
