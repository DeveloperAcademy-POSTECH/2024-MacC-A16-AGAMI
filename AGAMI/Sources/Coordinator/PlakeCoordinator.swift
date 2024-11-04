//
//  ArchiveCoordinator.swift
//  AGAMI
//
//  Created by 박현수 on 10/15/24.
//

import Foundation
import SwiftUI

enum PlakeRoute: Hashable {
    
    // 리스트 뷰
    enum List: Hashable {
        case listView
        case playlistView(viewModel: PlakePlaylistViewModel)
    }
    
    // 플레이크 생성 뷰
    enum Creation: Hashable {
        case newPlakeView
        case searchShazamingView
        case searchWritingView(viewModel: SearchWritingViewModel)
        case cameraView(viewModelContainer: CoordinatorViewModelContainer)
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        
        static func == (lhs: PlakeRoute.Creation, rhs: PlakeRoute.Creation) -> Bool {
            lhs.id == rhs.id
        }
    }
    
    // 맵 뷰
    enum Map: Hashable {
        case mapView
        case placeListView(viewModel: CollectionPlaceViewModel)
    }
    
    // 계정 뷰
    enum Account: Hashable {
        case accountView
        case deleteAccountView
    }
    
    case list(List)
    case creation(Creation)
    case map(Map)
    case account(Account)
    
    var id: String {
        switch self {
        case .list(let route):
            return route.id
        case .creation(let route):
            return route.id
        case .map(let route):
            return route.id
        case .account(let route):
            return route.id
        }
    }
}

extension PlakeRoute.List {
    var id: String {
        switch self {
        case .listView: return "listView"
        case .playlistView: return "playlistView"
        }
    }
}

extension PlakeRoute.Creation {
    var id: String {
        switch self {
        case .newPlakeView: return "newPlakeView"
        case .searchShazamingView: return "searchShazamingView"
        case .searchWritingView: return "searchWritingView"
        case .cameraView: return "cameraView"
        }
    }
}

extension PlakeRoute.Map {
    var id: String {
        switch self {
        case .mapView: return "mapView"
        case .placeListView: return "placeListView"
        }
    }
}

extension PlakeRoute.Account {
    var id: String {
        switch self {
        case .accountView: return "accountView"
        case .deleteAccountView: return "deleteAccountView"
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

final class PlakeCoordinator: BaseCoordinator<PlakeRoute, PlakeSheet, PlakeFullScreenCover> {
    @ViewBuilder
    func build(route: PlakeRoute) -> some View {
        switch route {
        case .list(let listRoute):
            buildListRoute(route: listRoute)
            
        case .creation(let creationRoute):
            buildCreationRoute(route: creationRoute)
            
        case .map(let mapRoute):
            buildMapRoute(route: mapRoute)
            
        case .account(let accountRoute):
            buildAccountRoute(route: accountRoute)
        }
    }
    
    @ViewBuilder
    func buildListRoute(route: PlakeRoute.List) -> some View {
        switch route {
        case .listView:
            PlakeListView()
        case let .playlistView(viewModel):
            PlakePlaylistView(viewModel: viewModel)
        }
    }
    
    @ViewBuilder
    func buildCreationRoute(route: PlakeRoute.Creation) -> some View {
        switch route {
        case .newPlakeView:
            SearchStartView()
        case .searchShazamingView:
            SearchShazamingView()
        case let .searchWritingView(viewModel):
            SearchWritingView(viewModel: viewModel)
        case let .cameraView(viewModelContainer):
            CameraView(viewModelContainer: viewModelContainer)
        }
    }
    
    @ViewBuilder
    func buildMapRoute(route: PlakeRoute.Map) -> some View {
        switch route {
        case .mapView:
            MapView()
        case let .placeListView(viewModel):
            CollectionPlaceView(viewModel: viewModel)
        }
    }
    
    @ViewBuilder
    func buildAccountRoute(route: PlakeRoute.Account) -> some View {
        switch route {
        case .accountView:
            EmptyView() // TODO: 연결 예정
        case .deleteAccountView:
            EmptyView() // TODO: 연결 예정
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
