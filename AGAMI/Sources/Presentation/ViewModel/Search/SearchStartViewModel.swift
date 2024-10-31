//
//  SearchStartViewModel.swift
//  AGAMI
//
//  Created by Seoyeon Choi on 10/16/24.
//

import SwiftUI

import ShazamKit

@MainActor
@Observable
final class SearchStartViewModel: NSObject {
    private let persistenceService = PersistenceService.shared
    private let shazamService = ShazamService()
    private let locationService = LocationService.shared
    
    var currentItem: SHMediaItem?
    var diggingList: [SongModel] = []
    
    var shazamStatus: ShazamStatus = .idle
    var showSheet: Bool = false
    
    override init() {
        super.init()
        shazamService.delegate = self
        loadSavedSongs()
    }
    
    private func startRecognition() {
        shazamStatus = .searching
        shazamService.startRecognition()
    }
    
    func stopRecognition() {
        shazamService.stopRecognition()
    }
    
    func searchButtonTapped() {
        currentItem = nil

        if shazamStatus == .searching {
            stopRecognition()
            shazamStatus = .idle
        } else {
            startRecognition()
        }
    }
    
    func loadSavedSongs() {
        do {
            self.diggingList = try persistenceService.loadDiggingListWithOrder()
        } catch {
            dump("Failed to load saved songs: \(error)")
        }
    }
    
    func deleteSong(indexSet: IndexSet) {
        for index in indexSet {
            let songToDelete = diggingList[index]
            diggingList.remove(at: index)
            
            if let song = songToDelete as? SwiftDataSongModel {
                do {
                    try persistenceService.deleteSong(item: song)
                    loadSavedSongs()
                } catch {
                    dump("Error deleting song: \(error)")
                }
            } else {
                dump("Error: Song is not of type SwiftDataSongModel")
            }
        }
    }
    
    func moveSong(from source: IndexSet, to destination: Int) {
        diggingList.move(fromOffsets: source, toOffset: destination)
        persistenceService.saveDiggingListOrder(diggingList)
    }
}

extension SearchStartViewModel: ShazamServiceDelegate {
    func shazamService(_ service: ShazamService, didFind match: SHMatch) {
        dump(#function)
        guard let mediaItem = match.mediaItems.first else { return }
        dump("title: \(mediaItem.title ?? "")")
        stopRecognition()
        currentItem = mediaItem
        shazamStatus = .found
        
        if let item = currentItem {
            do {
                try persistenceService.saveSongToDiggingList(from: item)
                loadSavedSongs()
            } catch {
                dump("Failed to save song: \(error)")
            }
        }
    }
    
    func shazamService(_ service: ShazamService, didNotFindMatchFor signature: SHSignature, error: (any Error)?) {
        dump(#function)
        dump("didNotFindMatch | signature: \(signature) | error: \(String(describing: error))")
        shazamStatus = .failed
        stopRecognition()
    }
    
    func shazamService(_ service: ShazamService, didFailWithError error: any Error) {
        dump(#function)
        shazamStatus = .failed
        stopRecognition()
    }
}
