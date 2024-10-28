//
//  LottieView.swift
//  AGAMI
//
//  Created by Seoyeon Choi on 10/28/24.
//

import SwiftUI

import Lottie

struct CustomLottieView: View {
    let lottie: LottieAnimationType
    let loopMode: LottieLoopMode
    let speed: CGFloat
    
    init(_ lottie: LottieAnimationType, loopMode: LottieLoopMode = .loop, speed: CGFloat = 1.0) {
        self.lottie = lottie
        self.loopMode = loopMode
        self.speed = speed
    }
    
    var body: some View {
        LottieView(animation: .named(lottie.filename, bundle: .module))
            .configure({ lottieView in
                lottieView.animationSpeed = speed
                lottieView.loopMode = loopMode
            })
            .playing()
    }
}

enum LottieAnimationType: String {
    case search
    
    var filename: String {
        switch self {
        case .search:
            "shazamLottie"
        }
    }
}
