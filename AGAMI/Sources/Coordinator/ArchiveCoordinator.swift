//
//  ArchiveCoordinator.swift
//  AGAMI
//
//  Created by 박현수 on 10/15/24.
//

import Foundation
import SwiftUI

enum ArchiveView: Hashable {
    case listView
    case playlistView
    case detailView(viewModel: ArchivePlaylistViewModel)
}

enum ArchiveSheet: String, Identifiable {
    var id: String { self.rawValue }

    case dummySheet
}

enum ArchiveFullScreenCover: String, Identifiable {
    var id: String { self.rawValue }

    case dummyFullScreenCover
}

@Observable
final class ArchiveCoordinator {
    var path: NavigationPath = .init()
    var sheet: ArchiveSheet?
    var fullScreenCover: ArchiveFullScreenCover?

    func push(view: ArchiveView) {
        path.append(view)
    }

    func pop() {
        path.removeLast()
    }

    func popToRoot() {
        path.removeLast(path.count)
    }

    func presentSheet(_ sheet: ArchiveSheet) {
        self.sheet = sheet
    }

    func presentFullScreenCover(_ cover: ArchiveFullScreenCover) {
        self.fullScreenCover = cover
    }

    func dismissSheet() {
        self.sheet = nil
    }

    func dismissFullScreenCover() {
        self.fullScreenCover = nil
    }

    @ViewBuilder
    func build(view: ArchiveView) -> some View {
        switch view {
        case .listView:
            ArchiveListView()
        case .playlistView:
            ArchivePlaylistView()
        case let .detailView(viewModel):
            ArchivePlaylistDetailView(viewModel: viewModel)
        }
    }

    @ViewBuilder
    func buildSheet(sheet: ArchiveSheet) -> some View {
        switch sheet {
        case .dummySheet:
            EmptyView()
        }
    }

    @ViewBuilder
    func buildFullScreenCover(cover: ArchiveFullScreenCover) -> some View {
        switch cover {
        case .dummyFullScreenCover:
            EmptyView()
        }
    }
}
