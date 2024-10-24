//
//  SearchCoordinator.swift
//  AGAMI
//
//  Created by Seoyeon Choi on 10/16/24.
//

import SwiftUI

enum SearchView: Hashable, Identifiable {
    var id: String {
        switch self {
        case .startView:
            return "startView"
        case .writingView:
            return "writingView"
        case .cameraView:
            return "cameraView"
        }
    }
    
    case startView
    case writingView
    case cameraView(viewModel: SearchWritingViewModel)
    
    // Hashable 직접 구현
    func hash(into hasher: inout Hasher) {
        switch self {
        case .startView:
            hasher.combine("startView")
        case .writingView:
            hasher.combine("writingView")
        case .cameraView:
            hasher.combine("cameraView")
            // 여기서 viewModel 자체를 해시하지 않음
        }
    }
    
    static func == (lhs: SearchView, rhs: SearchView) -> Bool {
        switch (lhs, rhs) {
        case (.startView, .startView),
            (.writingView, .writingView):
            return true
        case (.cameraView, .cameraView):
            return true  // 여기서 viewModel은 비교하지 않음
        default:
            return false
        }
    }
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
        case .cameraView(let viewModel):
            CameraView(searchWritingViewModel: viewModel)
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

