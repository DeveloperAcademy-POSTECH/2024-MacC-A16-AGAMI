//
//  AppleMusicLottieView.swift
//  AGAMI
//
//  Created by 박현수 on 10/29/24.
//

import SwiftUI
import Lottie

struct AppleMusicLottieView: View {
    var body: some View {
        ZStack {
            Color(.pWhite)
            VStack(spacing: 37) {
                CustomLottieView(.applemusicExporting)
                    .frame(width: 200, height: 200)
                Text("수집한 플레이크를\nApple Music으로 내보내는 중...")
                    .font(.pretendard(weight: .semiBold600, size: 24))
                    .foregroundStyle(Color(.pPrimary))
                    .multilineTextAlignment(.center)
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    SpotifyLottieView()
}
