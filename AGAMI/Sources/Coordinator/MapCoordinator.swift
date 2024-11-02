//
//  MapCoordinator.swift
//  AGAMI
//
//  Created by yegang on 10/31/24.
//

import Foundation
import SwiftUI

enum MapRoute: Hashable {
    var id: String {
        switch self {
        case .mapView:
            return "mapView"
        case .placeListView:
            return "placeListView"
        }
    }
    
    case mapView
    case placeListView(viewModel: CollectionPlaceViewModel)
}

enum MapSheet: String, Identifiable {
    var id: String { self.rawValue }
    
    case dummySheet
}

enum MapFullScreenCover: String, Identifiable {
    var id: String { self.rawValue }
    
    case dummyFullScreenCover
}

final class MapCoordinator: BaseCoordinator<MapRoute, MapSheet, MapFullScreenCover> {
    @ViewBuilder
    func build(route: MapRoute) -> some View {
        switch route {
        case .mapView:
            MapView()
        case let .placeListView(viewModel):
            CollectionPlaceView(viewModel: viewModel)
        }
    }
    
    @ViewBuilder
    func buildSheet(sheet: MapSheet) -> some View {
        switch sheet {
        case .dummySheet:
            EmptyView()
        }
    }
    
    @ViewBuilder
    func buildFullScreenCover(cover: MapFullScreenCover) -> some View {
        switch cover {
        case .dummyFullScreenCover:
            EmptyView()
        }
    }
}
