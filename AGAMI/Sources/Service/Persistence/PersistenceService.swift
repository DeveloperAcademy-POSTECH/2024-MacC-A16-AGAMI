//
//  PersistenceServiceImpl.swift
//  AGAMI
//
//  Created by 박현수 on 10/18/24.
//

import Foundation
import SwiftData

final class PersistenceService {
    let modelContainer: ModelContainer
    let modelContext: ModelContext

    init() {
        let schema = Schema([
            SwiftDataPlaylistModel.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            modelContext = ModelContext(modelContainer)
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    func createPlaylist(
        playlistName: String?,
        playlistDescription: String?,
        photoURL: String?,
        latitude: Double?,
        longitude: Double?
    ) throws {
        let item = SwiftDataPlaylistModel(
            playlistName: playlistName,
            playlistDescription: playlistDescription,
            photoURL: photoURL,
            latitude: latitude,
            longitude: longitude
        )
        modelContext.insert(item)
        try modelContext.save()
    }

    func fetchPlaylist() throws -> [SwiftDataPlaylistModel] {
        return try modelContext.fetch(FetchDescriptor<SwiftDataPlaylistModel>())
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
}
