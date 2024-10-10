//
//  ShazamViewModel.swift
//  AGAMI
//
//  Created by 박현수 on 10/10/24.
//

import Foundation
import ShazamKit

@MainActor
@Observable
final class ShazamViewModel: NSObject {
    var currentItem: SHMediaItem?
    var shazaming = false

    private let shazamService = ShazamService()

    override init() {
        super.init()
        shazamService.delegate = self
    }

    func startRecognition() {
        shazaming = true
        shazamService.startRecognition()
    }

    func stopRecognition() {
        shazaming = false
        shazamService.stopRecognition()
    }
}

extension ShazamViewModel: ShazamServiceDelegate {
    func shazamService(_ service: ShazamService, didFind match: SHMatch) {
        dump(#function)
        guard let mediaItem = match.mediaItems.first else { return }
        dump("title: \(mediaItem.title ?? "")")
        stopRecognition()
        currentItem = mediaItem
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
