//
//  ArchiveCoordinator.swift
//  AGAMI
//
//  Created by 박현수 on 10/15/24.
//

import Foundation
import SwiftUI

enum PlakeRoute: Hashable {
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
final class PlakeCoordinator: BaseCoordinator<PlakeRoute, PlakeSheet, PlakeFullScreenCover> {
    @ViewBuilder
    func build(route: PlakeRoute) -> some View {
        switch route {
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
