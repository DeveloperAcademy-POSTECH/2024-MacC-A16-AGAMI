//
//  ArchiveCoordinator.swift
//  AGAMI
//
//  Created by 박현수 on 10/15/24.
//

import Foundation
import SwiftUI

enum PlakeRoute: Hashable {
    case homeView
    
    case listView
    case playlistView(viewModel: PlakePlaylistViewModel)
    case addPlakingView(viewModel: AddPlakingViewModel)
    case addPlakingShazamView(viewModel: AddPlakingViewModel)

    case searchWritingView
    case searchAddSongView(viewModel: SearchAddSongViewModel)
    case cameraView(viewModelContainer: CoordinatorViewModelContainer)
    
    case mapView
    case placeListView(viewModel: CollectionPlaceViewModel)
    
    case accountView
    case deleteAccountView(viewModel: AccountViewModel)

    var id: String {
        switch self {
        case .homeView: return "homeView"
        case .listView: return "listView"
        case .playlistView: return "playlistView"
            
        case .searchWritingView: return "searchWritingView"
        case .searchAddSongView: return "searchAddSongView"
        case .cameraView: return "cameraView"
            
        case .mapView: return "mapView"
        case .placeListView: return "placeListView"
            
        case .accountView: return "accountView"
        case .deleteAccountView: return "deleteAccountView"
        case .addPlakingView: return "addPlakingView"
        case .addPlakingShazamView: return "addPlakingShazamView"
        }
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: PlakeRoute, rhs: PlakeRoute) -> Bool {
        lhs.id == rhs.id
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

final class PlakeCoordinator: BaseCoordinator<PlakeRoute, PlakeSheet, PlakeFullScreenCover> {
    @ViewBuilder
    // swiftlint:disable:next cyclomatic_complexity
    func build(route: PlakeRoute) -> some View {
        switch route {
        case .homeView:
            HomeView()
        case .listView:
            PlakeListView()
        case let .playlistView(viewModel):
            PlakePlaylistView(viewModel: viewModel)
        case .searchWritingView:
            SearchWritingView()
        case .searchAddSongView(let viewModel):
            SearchAddSongView(viewModel: viewModel)
        case let .cameraView(viewModelContainer):
            CameraView(viewModelContainer: viewModelContainer)
        case .mapView:
            MapView()
        case let .placeListView(viewModel):
            CollectionPlaceView(viewModel: viewModel)
        case .accountView:
            AccountView()
        case let .deleteAccountView(viewModel):
            SignOutView(viewModel: viewModel)
        case let .addPlakingView(viewModel):
            AddPlakingView(viewModel: viewModel)
        case let .addPlakingShazamView(viewModel):
            AddPlakingShazamView(viewModel: viewModel)
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
