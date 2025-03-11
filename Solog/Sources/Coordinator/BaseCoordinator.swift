//
//  BaseCoordinator.swift
//  AGAMI
//
//  Created by 박현수 on 10/10/24.
//

import Foundation
import SwiftUI

@Observable
class BaseCoordinator<Route: Hashable, Sheet: Identifiable, FullScreenCover: Identifiable> {
    var path: NavigationPath = .init()
    var sheet: Sheet?
    var fullScreenCover: FullScreenCover?
    var onDismiss: (() -> Void)?

    func push(route: Route) {
        path.append(route)
    }

    func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }

    func popToRoot() {
        path.removeLast(path.count)
    }

    func presentSheet(_ sheet: Sheet) {
        self.sheet = sheet
    }

    func presentFullScreenCover(_ cover: FullScreenCover) {
        self.fullScreenCover = cover
    }

    func dismissSheet() {
        self.sheet = nil
    }

    func dismissFullScreenCover() {
        self.fullScreenCover = nil
    }
}
