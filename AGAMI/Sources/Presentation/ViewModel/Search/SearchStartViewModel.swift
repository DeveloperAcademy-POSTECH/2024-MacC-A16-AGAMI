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
    var searchButtonToggle: Bool = false
    var shazaming = false
    
    override init() {
        super.init()
        shazamService.delegate = self
    }
    
    private func startRecognition() {
        shazaming = true
        shazamService.startRecognition()
    }
    
    func stopRecognition() {
        shazaming = false
        shazamService.stopRecognition()
    }

    private func transform(_ item: SHMediaItem) -> SongModel {
        var artworkURL: String = ""
        if let url = item.artworkURL {
            artworkURL = url.absoluteString
        }
        
        return SongModel(songID: item.appleMusicID ?? "",
                         title: item.title ?? "",
                         artist: item.artist ?? "",
                         albumCoverURL: artworkURL)
    }
    
    func searchButtonTapped() {
        searchButtonToggle.toggle()
        
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
        
        if let item = currentItem {
            let diggingData = transform(item)
            diggingList.append(diggingData)
        }
        print("diggingList: \(diggingList)")
    }
    
    nonisolated func shazamService(_ service: ShazamService, didNotFindMatchFor signature: SHSignature, error: (any Error)?) {
        dump(#function)
        dump("didNotFindMatch | signature: \(signature) | error: \(String(describing: error))")
    }
    
    func shazamService(_ service: ShazamService, didFailWithError error: any Error) {
        dump(#function)
        stopRecognition()
    }
}
