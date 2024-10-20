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
        case .diggingModalView:
            return "diggingModalView"
        }
    }
    
    case diggingModalView(viewModel: SearchStartViewModel)
}

enum SearchFullScreenCover: Identifiable {
    var id: String {
        switch self {
        case .playlistFullscreenView:
            return "playlistFullscreenView"
        }
    }
    
    case playlistFullscreenView(viewModel: SearchWritingViewModel)
}

@Observable
final class SearchCoordinator {
    var path: NavigationPath = .init()
    var sheet: SearchSheet?
    var fullScreenCover: SearchFullScreenCover?
    var onDismiss: (() -> Void)?
    
    func push(view: SearchView) {
        path.append(view)
    }
    
    func pop() {
        path.removeLast()
    }
    
    func popToRoot() {
        path.removeLast(path.count)
    }
    
    func presentSheet(_ sheet: SearchSheet, onDismiss: (() -> Void)?) {
        self.sheet = sheet
        self.onDismiss = onDismiss
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
            CameraView()
        }
    }
    
    @ViewBuilder
    func buildSheet(sheet: SearchSheet) -> some View {
        switch sheet {
        case .diggingModalView(let viewModel):
            SearchDiggingListModalView(viewModel: viewModel)
                .presentationDragIndicator(.visible)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .presentationDetents([.height(60), .medium, .large])
                .presentationCornerRadius(20)
                .presentationBackgroundInteraction(.enabled(upThrough: .large))
                .interactiveDismissDisabled()
                .bottomMaskForSheet()
        }
    }
    
    @ViewBuilder
    func buildFullScreenCover(cover: SearchFullScreenCover) -> some View {
        switch cover {
        case .playlistFullscreenView(let viewModel):
            SearchPlayListFullscreenVIew(viewModel: viewModel)
        }
    }
}

