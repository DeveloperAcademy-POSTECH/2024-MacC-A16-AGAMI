//
//  HomeViewModel.swift
//  AGAMI
//
//  Created by 박현수 on 10/10/24.
//

import Foundation

@Observable
final class HomeViewModel {
    var selectedTab: TabSelection = .plake

    func simpleHaptic() {
        HapticService.shared.playSimpleHaptic()
    }
}
