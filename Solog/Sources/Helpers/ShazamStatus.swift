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
    case moreSearching
    case found
    case failed
    
    var title: String? {
        switch self {
        case .idle, .found: return "음악 수집하기"
        case .searching: return "음악을 수집하는 중 ..."
        case .moreSearching: return "음악 수집을 계속 시도하는 중 ..."
        case .failed: return "다시 음악 수집하기"
        }
    }
    
    var subTitle: String? {
        switch self {
        case .idle, .found: return "지금 들려오는 음악을 수집하여 기록해보세요."
        case .searching: return "기기가 곡을 인식하고 있습니다. 기다려주세요."
        case .moreSearching: return "기기가 곡을 인식할 수 있도록 환경을 점검해주세요."
        case .failed: return "일치하는 콘텐츠를 찾을 수 없습니다."
        }
    }
    
    var titleColor: Color {
        switch self {
        case .idle, .found, .failed: return Color(.sTitleText)
        case .searching, .moreSearching: return Color(.sMain)
        }
    }

    var backgroundColor: Color {
        switch self {
        case .idle, .found, .failed: return Color(.sMain)
        case .searching, .moreSearching: return Color(.sButton)
        }
    }
}
