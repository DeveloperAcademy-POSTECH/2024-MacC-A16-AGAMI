//
//  SearchCoordinator.swift
//  AGAMI
//
//  Created by Seoyeon Choi on 10/16/24.
//

import SwiftUI

enum SearchView: Hashable {
    case startView
    case writingView
    case cameraView
}

enum SearchSheet: Identifiable {
    var id: String {
        switch self {
        case .playlistModalView:
            return "playlistModalView"
        case .diggingModalView:
            return "diggingModalView"
        }
    }
    
    case playlistModalView(viewModel: SearchStartViewModel)
    case diggingModalView(viewModel: SearchStartViewModel)
}

enum SearchFullScreenCover: String, Identifiable {
    var id: String { self.rawValue }
    
    case dummyFullScreenCover
}

@Observable
final class SearchCoordinator {
    var path: NavigationPath = .init()
    var sheet: SearchSheet?
    var fullScreenCover: SearchFullScreenCover?
    
    func push(view: SearchView) {
        path.append(view)
    }
    
    func pop() {
        path.removeLast()
    }
    
    func popToRoot() {
        path.removeLast(path.count)
    }
    
    func presentSheet(_ sheet: SearchSheet) {
        self.sheet = sheet
    }
    
    func presentFullScreenCover(_ cover: SearchFullScreenCover) {
        self.fullScreenCover = cover
    }
    
    func dismissSheet() {
        self.sheet = nil
    }
    
    func dismissFullScreenCover() {
        self.fullScreenCover = nil
    }
    
    @ViewBuilder
    func build(view: SearchView) -> some View {
        switch view {
        case .startView:
            SearchStartView()
        case .writingView:
            SearchWritingView()
        case .cameraView:
            EmptyView()
        }
    }
    
    @ViewBuilder
    func buildSheet(sheet: SearchSheet) -> some View {
        switch sheet {
        case .playlistModalView(let viewModel):
            SearchPlaylistModalView(viewModel: viewModel)
                .presentationDragIndicator(.visible)
        case .diggingModalView(let viewModel):
            SearchPlaylistModalView(viewModel: viewModel)
                .presentationDragIndicator(.visible)
        }
    }
    
    @ViewBuilder
    func buildFullScreenCover(cover: SearchFullScreenCover) -> some View {
        switch cover {
        case .dummyFullScreenCover:
            EmptyView()
        }
    }
}

