//
//  ShazamHomeView.swift
//  AGAMI
//
//  Created by 박현수 on 10/10/24.
//

import SwiftUI
import ShazamKit
import AVKit

struct ShazamHomeView: View {
    @State private var viewModel = ViewModel()

    var body: some View {
        NavigationView {
            VStack(spacing: 8) {
                Spacer()
                AsyncImage(url: viewModel.currentItem?.artworkURL) { image in
                    image.image?.resizable().scaledToFit()
                }
                .frame(width: 200, height: 200, alignment: .center)

                Text(viewModel.currentItem?.title ?? "Press the Button below to Shazam")
                    .font(.title3.bold())

                Text(viewModel.currentItem?.artist ?? "")
                    .font(.body)
                Spacer()
                if viewModel.shazaming == true {
                    Button("Stop Shazaming") {
                        viewModel.stopRecognition()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                } else {
                    Button("Start Shazaming") {
                        viewModel.startRecognition()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
            .navigationTitle("Shazam")
        }
    }
}

@Observable
final class ViewModel: NSObject {
    var currentItem: SHMediaItem?
    var shazaming = false

    @ObservationIgnored private let session = SHSession()
    @ObservationIgnored private let audioEngine = AVAudioEngine()
    @ObservationIgnored private var timer: Timer?

    override init() {
        super.init()
        session.delegate = self
    }

    private func startTimer() {
        dump(#function)
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in
            dump("10초 지났다! 샤잠 꺼")
            self?.stopRecognition()
        }
    }
    private func stopTimer() {
        dump(#function)
        timer?.invalidate()
        timer = nil
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

        inputNode.installTap(onBus: .zero, bufferSize: 1024, format: recordingFormat) { [weak session] buffer, _ in
            session?.matchStreamingBuffer(buffer, at: nil)
        }
    }

    private func startAudioRecording() throws {
        dump(#function)
        try audioEngine.start()
        shazaming = true
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
            dump(error.localizedDescription)
        }
    }

    func stopRecognition() {
        dump(#function)
        shazaming = false
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: .zero)
        stopTimer()
    }
}

extension ViewModel: SHSessionDelegate {
    func session(_ session: SHSession, didFind match: SHMatch) {
        dump(#function)
        guard let mediaItem = match.mediaItems.first else { return }
        DispatchQueue.main.async { [weak self] in
            self?.stopRecognition()
            self?.currentItem = mediaItem
        }
    }
}
