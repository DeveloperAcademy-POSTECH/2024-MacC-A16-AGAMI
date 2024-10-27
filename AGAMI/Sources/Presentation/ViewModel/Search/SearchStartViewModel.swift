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
        startRecognition()
    }
    
    func loadSavedSongs() {
        do {
            self.diggingList = try persistenceService.fetchDiggingList()
        } catch {
            print("Failed to load saved songs: \(error)")
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
                    print("Error deleting song: \(error)")
                }
            } else {
                print("Error: Song is not of type SwiftDataSongModel")
            }
        }
    }
    
    func moveSong(from source: IndexSet, to destination: Int) {
        diggingList.move(fromOffsets: source, toOffset: destination)
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

enum ShazamStatus {
    case idle
    case searching
    case found
    case failed
    
    var title: String {
        switch self {
        case .idle: return "플레이크를 눌러 디깅하기"
        case .searching: return "플레이킹중..."
        case .found: return "노래를 찾았습니다. 확인해보세요!"
        case .failed: return "플레이크로 다시 디깅하기"
        }
    }
    
    var subTitle: String? {
        switch self {
        case .idle: return "지금 들리는 노래를 디깅해보세요."
        case .failed: return "주변 소음을 확인해보세요."
        case .searching, .found: return nil
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .idle, .searching, .found: return Color(.pPrimary)
        case .failed: return Color(.pGray1)
        }
    }
}
