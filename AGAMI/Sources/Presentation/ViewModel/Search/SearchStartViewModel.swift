//
//  SearchStartViewModel.swift
//  AGAMI
//
//  Created by Seoyeon Choi on 10/16/24.
//

import Foundation

import ShazamKit

@MainActor
@Observable
final class SearchStartViewModel: NSObject {
    private let shazamService = ShazamService()
    
    var currentItem: SHMediaItem?
    var diggingList: [SongModel] = []
    
    var shazamStatus: ShazamStatus = .idle
    var showSheet: Bool = false
    
    override init() {
        super.init()
        shazamService.delegate = self
    }
    
    private func startRecognition() {
        shazamStatus = .searching
        shazamService.startRecognition()
    }
    
    func stopRecognition() {
        shazamStatus = .idle
        shazamService.stopRecognition()
    }
    
    func searchButtonTapped() {
        currentItem = nil
        startRecognition()
    }
    
    func deleteSong(indexSet: IndexSet) {
        for index in indexSet {
            diggingList.remove(at: index)
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
            let diggingData = ModelAdapter.fromSHtoSwiftDataSong(item)
            diggingList.append(diggingData)
        }
    }
    
    func shazamService(_ service: ShazamService, didNotFindMatchFor signature: SHSignature, error: (any Error)?) {
        dump(#function)
        dump("didNotFindMatch | signature: \(signature) | error: \(String(describing: error))")
        shazamStatus = .failed
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
    
    var buttonDescription: String {
        switch self {
        case .idle:
            return "서치 시작"
        case .searching:
            return "서치 중"
        case .found:
            return "노래 찾음"
        case .failed:
            return "다시 시도"
        }
    }
}
