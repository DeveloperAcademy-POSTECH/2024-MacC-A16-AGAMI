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
    
    case newPlakeView
    case searchShazamingView
    case searchWritingView(viewModel: SearchStartViewModel)
    case cameraView(viewModel: SearchWritingViewModel)
    
    // Hashable 직접 구현
    func hash(into hasher: inout Hasher) {
        switch self {
        case .listView:
            hasher.combine("listView")
        case .playlistView:
            hasher.combine("playlistView")
        case .newPlakeView:
            hasher.combine("newPlakeView")
        case .searchShazamingView:
            hasher.combine("searchShazamingView")
        case .searchWritingView:
            hasher.combine("searchWritingView")
        case .cameraView:
            hasher.combine("cameraView")
        }
    }
    
    static func == (lhs: PlakeRoute, rhs: PlakeRoute) -> Bool {
        switch (lhs, rhs) {
        case (.listView, .listView),
            (.playlistView, .playlistView),
            (.newPlakeView, .newPlakeView),
            (.searchShazamingView, .searchShazamingView),
            (.searchWritingView, .searchWritingView),
            (.cameraView, .cameraView):
            return true
        default:
            return false
        }
    }
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
        case .newPlakeView:
            SearchStartView()
        case .searchShazamingView:
            SearchShazamingView()
        case .searchWritingView(let viewModel):
            SearchWritingView(searchStartViewModel: viewModel)
        case .cameraView(let viewModel):
            CameraView(searchWritingViewModel: viewModel)
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
