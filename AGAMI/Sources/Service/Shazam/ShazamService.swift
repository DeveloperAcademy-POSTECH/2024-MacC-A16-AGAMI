//
//  ShazamService.swift
//  AGAMI
//
//  Created by 박현수 on 10/10/24.
//
import Foundation
import ShazamKit
import AVKit

final class ShazamService: NSObject {
    private let session = SHSession()
    private let audioEngine = AVAudioEngine()
    private var shazamContinuation: CheckedContinuation<SHMatch, Error>?

    static let shared: ShazamService = .init()

    override init() {
        super.init()
        session.delegate = self
    }

    func startRecognition() async throws -> SHMatch {
        return try await withCheckedThrowingContinuation { continuation in
            shazamContinuation = continuation
            if audioEngine.isRunning {
                stopRecognition()
                continuation.resume(throwing: ShazamError.isRunning)
                return
            }
            do {
                try prepareAudioRecording()
                generateSignature()
                try startAudioRecording()
            } catch {
                continuation.resume(throwing: ShazamError.didFail)
                return
            }
        }
    }

    func stopRecognition() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: .zero)
        if let continuation = shazamContinuation {
            shazamContinuation = nil
            continuation.resume(throwing: ShazamError.cancelled)
        }
    }

    private func prepareAudioRecording() throws {
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
    }

    private func generateSignature() {
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: .zero)

        inputNode.installTap(onBus: .zero, bufferSize: 4096, format: recordingFormat) { [weak self] buffer, _ in
            self?.session.matchStreamingBuffer(buffer, at: nil)
        }
    }

    private func startAudioRecording() throws {
        try audioEngine.start()
    }
}

extension ShazamService: SHSessionDelegate {
    func session(_ session: SHSession, didFind match: SHMatch) {
        Task { @MainActor in
            shazamContinuation?.resume(returning: match)
            shazamContinuation = nil
            stopRecognition()
        }
    }

    func session(_ session: SHSession, didNotFindMatchFor signature: SHSignature, error: (any Error)?) {
        Task { @MainActor in
            shazamContinuation?.resume(throwing: ShazamError.didNotFindMatch)
            shazamContinuation = nil
            stopRecognition()
        }
    }

    func session(_ session: SHSession, didFailWithError error: Error) {
        Task { @MainActor in
            shazamContinuation?.resume(throwing: ShazamError.didFail)
            shazamContinuation = nil
            stopRecognition()
        }
    }
}
