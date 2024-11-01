//
//  SearchShazamingViewModel.swift
//  AGAMI
//
//  Created by Seoyeon Choi on 11/1/24.
//

import SwiftUI

import ShazamKit

@MainActor
@Observable
final class SearchShazamingViewModel: NSObject {
    private let persistenceService = PersistenceService.shared
    private let shazamService = ShazamService()
    
    var currentItem: SHMediaItem?
    var shazamStatus: ShazamStatus = .idle
    
    override init() {
        super.init()
        shazamService.delegate = self
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
}

extension SearchShazamingViewModel: ShazamServiceDelegate {
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

