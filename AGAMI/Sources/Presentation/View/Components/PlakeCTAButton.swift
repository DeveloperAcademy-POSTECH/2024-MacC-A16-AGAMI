//
//  PlakeCTAButton.swift
//  AGAMI
//
//  Created by Seoyeon Choi on 11/1/24.
//

import SwiftUI

struct PlakeCTAButton: View {
    var type: PlakeCTAButtonType
    
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .foregroundStyle(type.backgroundColor)
            .overlay {
                HStack(spacing: 0) {
                    if let image = type.buttonImage {
                        image
                            .padding(.trailing, 6)
                    }
                    
                    Text(type.buttonTitle)
                }
                .font(.pretendard(weight: .medium500, size: 20))
                .kerning(-0.41)
                .foregroundStyle(type.buttonTItleColor)
            }
            .frame(height: 50)
            .padding(.horizontal, 8)
    }
}

enum PlakeCTAButtonType {
    case plaking
    case addSong
    case cancel
    case logout
    
    var backgroundColor: Color {
        switch self {
        case .plaking, .addSong, .logout: return Color(.pPrimary)
        case .cancel: return Color(.pWhite)
        }
    }
    
    var buttonTitle: String {
        switch self {
        case .plaking: return "플레이킹"
        case .addSong: return "노래 추가하기"
        case .cancel: return "취소하기"
        case .logout: return "로그아웃"
        }
    }
    
    var buttonImage: Image? {
        switch self {
        case .plaking: return Image(.plakingButtonLogo)
        case .addSong: return Image(systemName: "plus")
        case .cancel, .logout: return nil
        }
    }
    
    var buttonTItleColor: Color {
        switch self {
        case .plaking, .addSong, .logout: return Color(.pWhite)
        case .cancel: return Color(.pPrimary)
        }
    }
}
