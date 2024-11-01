//
//  ArchiveCoordinator.swift
//  AGAMI
//
//  Created by 박현수 on 10/15/24.
//

import Foundation
import SwiftUI

enum PlakeView: Hashable {
    case listView
    case playlistView(viewModel: PlakePlaylistViewModel)
}

enum PlakeSheet: String, Identifiable {
    var id: String { self.rawValue }

    case dummySheet
}

enum PlakeFullScreenCover: String, Identifiable {
    var id: String { self.rawValue }

    case dummyFullScreenCover
}

@Observable
final class PlakeCoordinator {
    var path: NavigationPath = .init()
    var sheet: PlakeSheet?
    var fullScreenCover: PlakeFullScreenCover?

    func push(view: PlakeView) {
        path.append(view)
    }

    func pop() {
        path.removeLast()
    }

    func popToRoot() {
        path.removeLast(path.count)
    }

    func presentSheet(_ sheet: PlakeSheet) {
        self.sheet = sheet
    }

    func presentFullScreenCover(_ cover: PlakeFullScreenCover) {
        self.fullScreenCover = cover
    }

    func dismissSheet() {
        self.sheet = nil
    }

    func dismissFullScreenCover() {
        self.fullScreenCover = nil
    }

    @ViewBuilder
    func build(view: PlakeView) -> some View {
        switch view {
        case .listView:
            PlakeListView()
        case let .playlistView(viewModel):
            PlakePlaylistView(viewModel: viewModel)
        }
    }

    @ViewBuilder
    func buildSheet(sheet: PlakeSheet) -> some View {
        switch sheet {
        case .dummySheet:
            EmptyView()
        }
    }

    @ViewBuilder
    func buildFullScreenCover(cover: PlakeFullScreenCover) -> some View {
        switch cover {
        case .dummyFullScreenCover:
            EmptyView()
        }
    }
}
