//
//  HapticService.swift
//  AGAMI
//
//  Created by 박현수 on 11/17/24.
//

import CoreHaptics
import Foundation

final class HapticService {
    private var hapticEngine: CHHapticEngine?
    private var isSupported: Bool = false

    static let shared = HapticService()

    private let simpleHapticEvent = [
        CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [],
            relativeTime: 0
        )
    ]

    private let longHapticEvent = [
        CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
            ],
            relativeTime: 0.0
        ),
        CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.7),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.7)
            ],
            relativeTime: 0.1,
            duration: 0.5
        )
    ]

    private init() {
        setupHapticEngine()
    }

    private func setupHapticEngine() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            dump("Haptics not supported on this device.")
            return
        }
        isSupported = true

        do {
            hapticEngine = try CHHapticEngine()
            hapticEngine?.isAutoShutdownEnabled = true
        } catch {
            dump("Failed to create haptic engine: \(error)")
        }
    }

    func playSimpleHaptic() {
        guard isSupported,
              let pattern = try? CHHapticPattern(events: simpleHapticEvent, parameters: []),
              let player = try? hapticEngine?.makePlayer(with: pattern)
        else { return }

        try? hapticEngine?.start()
        try? player.start(atTime: CHHapticTimeImmediate)
    }

    func playLongHaptic() {
        guard isSupported,
              let pattern = try? CHHapticPattern(events: longHapticEvent, parameters: []),
              let player = try? hapticEngine?.makePlayer(with: pattern)
        else { return }

        try? hapticEngine?.start()
        try? player.start(atTime: CHHapticTimeImmediate)
    }
}
