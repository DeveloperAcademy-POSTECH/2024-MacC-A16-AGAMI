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
    
    func startRecognition() {
        checkMicrophonePermission { [weak self] granted in
            guard let self = self else { return }
            if granted {
                self.shazamStatus = .searching
                self.shazamService.startRecognition()
            } else {
                self.shazamStatus = .idle
            }
        }
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
    
    private func checkMicrophonePermission(completion: @escaping (Bool) -> Void) {
        switch AVAudioApplication.shared.recordPermission {
        case .denied:
            completion(false)
        case .granted:
            completion(true)
        case .undetermined:
            AVAudioApplication.requestRecordPermission { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        @unknown default:
            completion(false)
        }
    }
}

extension SearchShazamingViewModel: ShazamServiceDelegate {
    func shazamService(_ service: ShazamService, didFind match: SHMatch) {
        guard let mediaItem = match.mediaItems.first else { return }
        stopRecognition()
        currentItem = mediaItem
        shazamStatus = .found
        
        if let item = currentItem {
            HapticService.shared.playLongHaptic()
            persistenceService.appendSong(from: item)
        }
    }
    
    func shazamService(_ service: ShazamService, didNotFindMatchFor signature: SHSignature, error: (any Error)?) {
        HapticService.shared.playLongHaptic()
        shazamStatus = .failed
        stopRecognition()
    }
    
    func shazamService(_ service: ShazamService, didFailWithError error: any Error) {
        HapticService.shared.playLongHaptic()
        shazamStatus = .failed
        stopRecognition()
    }
}
