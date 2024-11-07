//
//  ShazamService.swift
//  AGAMI
//
//  Created by 박현수 on 10/10/24.
//
import Foundation
import ShazamKit
import AVKit

protocol ShazamServiceDelegate: AnyObject {
    @MainActor func shazamService(_ service: ShazamService, didFind match: SHMatch)
    @MainActor func shazamService(_ service: ShazamService, didNotFindMatchFor signature: SHSignature, error: (any Error)?)
    @MainActor func shazamService(_ service: ShazamService, didFailWithError error: Error)
}

final class ShazamService: NSObject {
    weak var delegate: ShazamServiceDelegate?

    private let session = SHSession()
    private let audioEngine = AVAudioEngine()
    private var timer: Timer?

    override init() {
        super.init()
        session.delegate = self
    }

    func startRecognition() {
        dump(#function)
        do {
            if audioEngine.isRunning {
                stopRecognition()
                return
            }

            try prepareAudioRecording()
            generateSignature()
            try startAudioRecording()
            startTimer()
        } catch {
            Task { @MainActor in
                self.delegate?.shazamService(self, didFailWithError: error)
            }
        }
    }

    func stopRecognition() {
        dump(#function)
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: .zero)
        stopTimer()
    }

    private func prepareAudioRecording() throws {
        dump(#function)
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
    }

    private func generateSignature() {
        dump(#function)
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: .zero)

        inputNode.installTap(onBus: .zero, bufferSize: 4096, format: recordingFormat) { [weak self] buffer, _ in
            self?.session.matchStreamingBuffer(buffer, at: nil)
        }
    }

    private func startAudioRecording() throws {
        dump(#function)
        try audioEngine.start()
    }

    private func startTimer() {
        dump(#function)
        timer = Timer.scheduledTimer(withTimeInterval: 20, repeats: true) { [weak self] _ in
            dump("20초 경과 샤잠 종료")
            self?.stopRecognition()
        }
    }

    private func stopTimer() {
        dump(#function)
        timer?.invalidate()
        timer = nil
    }
}

extension ShazamService: SHSessionDelegate {
    func session(_ session: SHSession, didFind match: SHMatch) {
        Task { @MainActor in
            self.delegate?.shazamService(self, didFind: match)
        }
    }

    func session(_ session: SHSession, didNotFindMatchFor signature: SHSignature, error: (any Error)?) {
        Task { @MainActor in
            self.delegate?.shazamService(self, didNotFindMatchFor: signature, error: error)
        }
    }

    func session(_ session: SHSession, didFailWithError error: Error) {
        Task { @MainActor in
            self.delegate?.shazamService(self, didFailWithError: error)
        }
    }
}
