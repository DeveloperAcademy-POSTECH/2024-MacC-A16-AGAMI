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
            Image(.halftonePinkBack)
            CustomLottieView(.applemusicExporting)
                .padding(.top, 80)
            Text("수집한 플레이크를\nApple Music로 내보내는 중...")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Color(.pPrimary))
                .multilineTextAlignment(.center)
                .padding(.top, 330)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    AppleMusicLottieView()
}
