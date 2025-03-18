//
//  CollectionPlaceView.swift
//  AGAMI
//
//  Created by yegang on 10/14/24.
//

import SwiftUI
import Kingfisher

struct CollectionPlaceView: View {
    @State var viewModel: CollectionPlaceViewModel
    @Environment(\.scenePhase) private var scenePhase
    @Environment(SologCoordinator.self) private var sologCoord
    @Environment(MapCoordinator.self) private var mapCoord

    init(viewModel: CollectionPlaceViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }
    
    var body: some View {
        GeometryReader { proxy in
            ListView(viewModel: viewModel, size: proxy.size)
        }
        .safeAreaPadding(.horizontal, 16)
        .navigationTitle("기록 지도")
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("닫기") {
                    sologCoord.dismissSheet()
                }
                .foregroundStyle(Color(.sButton))
            }
        }
    }
}

private struct ListView: View {
    @Environment(SologCoordinator.self) private var sologCoord
    let viewModel: CollectionPlaceViewModel
    let size: CGSize
    private var verticalSpacingValue: CGFloat { size.width / 377 * 15 }

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: verticalSpacingValue) {
                ForEach(viewModel.playlists, id: \.playlistID) { playlist in
                    SologListCell(playlist: playlist, size: size) {
                        viewModel.simpleHaptic()
                        sologCoord.dismissSheet()
                        Task {
                            try await Task.sleep(for: .milliseconds(300))
                            await MainActor.run {
                                sologCoord.push(route: .playlistView(viewModel: .init(playlist: playlist)))
                            }
                        }
                    }
                }
                .scrollTransition(.animated, axis: .vertical) { content, phase in
                    content
                        .scaleEffect(phase.isIdentity ? 1 : 0.8)
                        .opacity(phase.isIdentity ? 1 : 0.5)
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned(limitBehavior: getAlwaysByOneIfAvailableElseAlways()))
    }
}
