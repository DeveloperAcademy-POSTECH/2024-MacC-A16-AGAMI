//
//  PlakeCoordinator.swift
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
    case plakeAddSongView(viewModel: PlakePlaylistViewModel)
	case accountView
    case mapView(viewModel: MapViewModel)
    case playlistMapView(playlist: PlaylistModel)

    var id: String {
        switch self {
        case .searchAddSongView: return "searchAddSongView"
        case .plakeAddSongView: return "plakeAddSongView"
        case .accountView: return "accountView"
        case .mapView: return "mapView"
        case .playlistMapView: return "playlistMapView"
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
        case let .plakeAddSongView(viewModel):
            PlakeAddSongView(viewModel: viewModel)
                .interactiveDismissDisabled()
        case .accountView:
            AccountView()
                .interactiveDismissDisabled()
        case let .mapView(viewModel):
            MapView(viewModel: viewModel)
                .interactiveDismissDisabled()
        case let .playlistMapView(playlist):
            PlaylistMapView(playlist: playlist)
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
