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

    private var _playlist: SwiftDataPlaylistModel?

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

    private func createPlaylist(
        playlistName: String = "",
        playlistDescription: String = "",
        photoURL: String = "",
        latitude: Double = 0.0,
        longitude: Double = 0.0,
        streetAddress: String = ""
    ) -> SwiftDataPlaylistModel {
        let playlist = SwiftDataPlaylistModel(
            playlistName: playlistName,
            playlistDescription: playlistDescription,
            photoURL: photoURL,
            latitude: latitude,
            longitude: longitude,
            streetAddress: streetAddress
        )

        _playlist = playlist
        modelContext.insert(playlist)
        return playlist
    }

    func fetchPlaylist() -> PlaylistModel {
        let fetchDescriptor = FetchDescriptor<SwiftDataPlaylistModel>()
        guard let result = try? modelContext.fetch(fetchDescriptor)
        else { return SwiftDataPlaylistModel() }

        if result.isEmpty {
            return createPlaylist()
        } else {
            _playlist = result.first
            return _playlist ?? SwiftDataPlaylistModel()
        }
    }

    func updatePlaylist() {
        do {
            try modelContext.save()
        } catch {
            dump(error)
        }
    }

    func deletePlaylist() {
        guard let playlist = _playlist else { return }
        modelContext.delete(playlist)
        _playlist = nil
        updatePlaylist()
    }
    
    func fetchDiggingList() throws -> [SongModel] {
        let fetchDescriptor = FetchDescriptor<SwiftDataSongModel>()
        return try modelContext.fetch(fetchDescriptor)
    }
    
    func saveSongToDiggingList(from mediaItem: SHMediaItem) throws {
        guard let playlist = fetchPlaylist() as? SwiftDataPlaylistModel
        else { return }

        let song = ModelAdapter.fromSHtoSwiftDataSong(mediaItem)
        playlist.swiftDataSongs.append(song)
        updatePlaylist()
    }
    
    func deleteSong(item: SongModel) {
        guard let playlist = _playlist,
              let index = playlist.swiftDataSongs.firstIndex(where: { $0.songID == item.songID })
        else { return }

        playlist.swiftDataSongs.remove(at: index)
        updatePlaylist()
    }
    
    func deleteAllSongs() {
        guard let playlist = _playlist else { return }
        playlist.swiftDataSongs.removeAll()
        updatePlaylist()
    }

    func moveSong(from source: IndexSet, to destination: Int) {
        guard let playlist = _playlist else { return }
        var updatedSongs = playlist.swiftDataSongs.sorted { $0.orderIndex ?? 0 < $1.orderIndex ?? 0 }
        updatedSongs.move(fromOffsets: source, toOffset: destination)
        for (index, song) in updatedSongs.enumerated() {
            song.orderIndex = index
        }
        updatePlaylist()
    }

}
