//
//  AppCoordinator.swift
//  AGAMI
//
//  Created by 박현수 on 10/10/24.
//

import Foundation
import SwiftUI

enum AppView: Hashable {
    case dummyView
}

enum AppSheet: String, Identifiable {
    var id: String { self.rawValue }

    case dummySheet
}

enum AppFullScreenCover: String, Identifiable {
    var id: String { self.rawValue }

    case dummyFullScreenCover
}

@Observable
final class AppCoordinator {
    var path: NavigationPath = .init()
    var sheet: AppSheet?
    var fullScreenCover: AppFullScreenCover?

    func push(view: AppView) {
        path.append(view)
    }

    func pop() {
        path.removeLast()
    }

    func popToRoot() {
        path.removeLast(path.count)
    }

    func presentSheet(_ sheet: AppSheet) {
        self.sheet = sheet
    }

    func presentFullScreenCover(_ cover: AppFullScreenCover) {
        self.fullScreenCover = cover
    }

    func dismissSheet() {
        self.sheet = nil
    }

    func dismissFullScreenCover() {
        self.fullScreenCover = nil
    }
}
