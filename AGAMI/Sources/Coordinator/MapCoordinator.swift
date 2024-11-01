//
//  MapCoordinator.swift
//  AGAMI
//
//  Created by yegang on 10/31/24.
//

import Foundation
import SwiftUI

enum PlaceMapView: Hashable {
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

@Observable
final class MapCoordinator {
    var path: NavigationPath = .init()
    var sheet: MapSheet?
    var fullScreenCover: MapFullScreenCover?
    var onDismiss: (() -> Void)?
    
    func push(view: PlaceMapView) {
        path.append(view)
    }
    
    func pop() {
        path.removeLast()
    }
    
    func popToRoot() {
        path.removeLast(path.count)
    }
    
    func presentSheet(_ sheet: MapSheet) {
        self.sheet = sheet
    }
    
    func presentFullScreenCover(_ cover: MapFullScreenCover) {
        self.fullScreenCover = cover
    }
    
    func dismissSheet() {
        self.sheet = nil
    }
    
    func dismissFullScreenCover() {
        self.fullScreenCover = nil
    }
    
    @ViewBuilder
    func build(view: PlaceMapView) -> some View {
        switch view {
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
