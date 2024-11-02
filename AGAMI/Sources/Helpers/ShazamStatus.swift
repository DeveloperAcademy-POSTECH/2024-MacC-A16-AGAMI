//
//  ShazamStatus.swift
//  AGAMI
//
//  Created by 박현수 on 10/31/24.
//

import SwiftUI

enum ShazamStatus {
    case idle
    case searching
    case found
    case failed

    var title: String? {
        switch self {
        case .idle: return "플레이크를 눌러 디깅하기"
        case .searching: return "플레이킹 중 ..."
        case .found: return "노래를 찾았습니다. 확인해보세요!"
        case .failed: return "플레이크를 눌러 다시 디깅하기"
        }
    }

    var subTitle: String? {
        switch self {
        case .idle: return "지금 들리는 노래를 디깅해보세요."
        case .failed: return "주변 소음을 확인해보세요."
        case .searching, .found: return nil
        }
    }

    var backgroundColor: [Color] {
        switch self {
        case .idle, .searching, .found: return GradientColors.pink
        case .failed: return GradientColors.gray
        }
    }
}
