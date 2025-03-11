//
//  MapCoordinator.swift
//  AGAMI
//
//  Created by 박현수 on 11/22/24.
//

import Foundation
import SwiftUI

enum MapRoute: Hashable {
    case collectionPlaceView(viewModel: CollectionPlaceViewModel)

    var id: String {
        switch self {
        case .collectionPlaceView: return "collectionPlaceView"
        }
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: MapRoute, rhs: MapRoute) -> Bool {
        lhs.id == rhs.id
    }
}

enum MapSheet: String, Hashable, Identifiable {
    case dummySheet

    var id: String { self.rawValue }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

enum MapFullScreenCover: String, Identifiable {
    var id: String { self.rawValue }

    case dummyFullScreenCover
}

final class MapCoordinator: BaseCoordinator<MapRoute, MapSheet, MapFullScreenCover> {
    @ViewBuilder
    func build(route: MapRoute) -> some View {
        switch route {
        case let .collectionPlaceView(viewModel):
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
