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
    case searchListView(viewModel: SearchListViewModel)
    case addPlakingView(viewModel: AddPlakingViewModel)
    case addPlakingShazamView(viewModel: AddPlakingViewModel)
    
    case searchWritingView
    case cameraView(viewModelContainer: CoordinatorViewModelContainer)

    case placeListView(viewModel: CollectionPlaceViewModel)

    case imageViewerView(urlString: String)

    var id: String {
        switch self {
        case .listView: return "listView"
        case .playlistView: return "playlistView"
        case .searchListView: return "searchListView"

        case .searchWritingView: return "searchWritingView"
        case .cameraView: return "cameraView"

        case .placeListView: return "placeListView"
            
        case .addPlakingView: return "addPlakingView"
        case .addPlakingShazamView: return "addPlakingShazamView"

        case .imageViewerView: return "imageViewerView"
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: PlakeRoute, rhs: PlakeRoute) -> Bool {
        lhs.id == rhs.id
    }
}

enum PlakeSheet: Hashable, Identifiable {
    case searchAddSongView(viewModel: SearchAddSongViewModel)
	case accountView
    case mapView(viewModel: MapViewModel)

    var id: String {
        switch self {
        case .searchAddSongView: return "searchAddSongView"
        case .accountView: return "accountView"
        case .mapView: return "mapView"
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: PlakeSheet, rhs: PlakeSheet) -> Bool {
        lhs.id == rhs.id
    }
}

enum PlakeFullScreenCover: String, Identifiable {
    var id: String { self.rawValue }
    
    case dummyFullScreenCover
}

final class PlakeCoordinator: BaseCoordinator<PlakeRoute, PlakeSheet, PlakeFullScreenCover> {
    @ViewBuilder
    func build(route: PlakeRoute) -> some View {
        switch route {
        case .listView:
            PlakeListView()
        case let .playlistView(viewModel):
            PlakePlaylistView(viewModel: viewModel)
        case let .searchListView(viewModel):
            SearchListView(viewModel: viewModel)
        case .searchWritingView:
            SearchWritingView()
        case let .cameraView(viewModelContainer):
            CameraView(viewModelContainer: viewModelContainer)
        case let .placeListView(viewModel):
            CollectionPlaceView(viewModel: viewModel)
        case let .addPlakingView(viewModel):
            AddPlakingView(viewModel: viewModel)
        case let .addPlakingShazamView(viewModel):
            AddPlakingShazamView(viewModel: viewModel)
        case let .imageViewerView(urlString):
            ImageViewerView(urlString: urlString)
        }
    }
    
    @ViewBuilder
    func buildSheet(sheet: PlakeSheet) -> some View {
        switch sheet {
        case let .searchAddSongView(viewModel):
            SearchAddSongView(viewModel: viewModel)
                .interactiveDismissDisabled()
        case .accountView:
            AccountView()
        case let .mapView(viewModel):
            MapView(viewModel: viewModel)
                .interactiveDismissDisabled()
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
