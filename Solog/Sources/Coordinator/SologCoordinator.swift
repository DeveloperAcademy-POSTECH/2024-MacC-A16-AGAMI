//
//  SologCoordinator.swift
//  AGAMI
//
//  Created by 박현수 on 10/15/24.
//

import Foundation
import SwiftUI

enum SologRoute: Hashable {
    case listView
    case playlistView(viewModel: SologPlaylistViewModel)
    case searchWritingView
    case placeListView(viewModel: CollectionPlaceViewModel)

    var id: String {
        switch self {
        case .listView: return "listView"
        case .playlistView: return "playlistView"
        case .searchWritingView: return "searchWritingView"
        case .placeListView: return "placeListView"
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: SologRoute, rhs: SologRoute) -> Bool {
        lhs.id == rhs.id
    }
}

enum SologSheet: Hashable, Identifiable {
    case searchAddSongView(viewModel: SearchAddSongViewModel)
    case sologAddSongView(viewModel: SologPlaylistViewModel)
	case accountView
    case mapView(viewModel: MapViewModel)
    case playlistMapView(playlist: PlaylistModel)

    var id: String {
        switch self {
        case .searchAddSongView: return "searchAddSongView"
        case .sologAddSongView: return "sologAddSongView"
        case .accountView: return "accountView"
        case .mapView: return "mapView"
        case .playlistMapView: return "playlistMapView"
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: SologSheet, rhs: SologSheet) -> Bool {
        lhs.id == rhs.id
    }
}

enum SologFullScreenCover: Hashable, Identifiable {
    var id: String {
        switch self {
        case .imageViewerView: return "imageViewerView"
        case .cameraView: return "cameraView"
        }
    }
    
    case imageViewerView(urlString: String)
    case cameraView(viewModelContainer: CoordinatorViewModelContainer)
}

final class SologCoordinator: BaseCoordinator<SologRoute, SologSheet, SologFullScreenCover> {
    @ViewBuilder
    func build(route: SologRoute) -> some View {
        switch route {
        case .listView:
            SologListView()
        case let .playlistView(viewModel):
            SologPlaylistView(viewModel: viewModel)
        case .searchWritingView:
            SearchWritingView()
        case let .placeListView(viewModel):
            CollectionPlaceView(viewModel: viewModel)
        }
    }
    
    @ViewBuilder
    func buildSheet(sheet: SologSheet) -> some View {
        switch sheet {
        case let .searchAddSongView(viewModel):
            SearchAddSongView(viewModel: viewModel)
                .interactiveDismissDisabled()
        case let .sologAddSongView(viewModel):
            SologAddSongView(viewModel: viewModel)
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
    func buildFullScreenCover(cover: SologFullScreenCover) -> some View {
        switch cover {
        case let .imageViewerView(urlString):
            ImageViewerView(urlString: urlString)
        case let .cameraView(viewModelContainer):
            CameraView(viewModel: .init(container: viewModelContainer))
        }
    }
}
