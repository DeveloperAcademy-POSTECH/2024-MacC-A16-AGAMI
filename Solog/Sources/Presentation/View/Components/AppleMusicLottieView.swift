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
            Color(.sWhite)
            VStack(spacing: 37) {
                ZStack {
                    CustomLottieView(.export)
                    Image(.exportAppleMusic)
                }
                Text("수집한 음악을\nApple Music으로 내보내는 중...")
                    .font(.notoSansKR(weight: .semiBold600, size: 22))
                    .foregroundStyle(Color(.sTitleText))
                    .multilineTextAlignment(.center)
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    AppleMusicLottieView()
}
