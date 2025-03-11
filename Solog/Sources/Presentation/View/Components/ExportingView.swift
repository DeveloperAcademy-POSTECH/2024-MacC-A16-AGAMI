//
//  SwiftUIView.swift
//  AGAMI
//
//  Created by yegang on 1/9/25.
//

import SwiftUI

struct ExportingView: View {
    var exportingState: ExportingState
    
    var body: some View {
        switch exportingState {
        case .isAppleMusicExporting:
            AppleMusicLottieView()
        case .isSpotifyExporting:
            SpotifyLottieView()
        case .none:
            EmptyView()
        }
    }
}
