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
    @Environment(PlakeCoordinator.self) private var plakeCoord
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
                    plakeCoord.dismissSheet()
                }
                .foregroundStyle(Color(.sButton))
            }
        }
    }
}

private struct ListView: View {
    let viewModel: CollectionPlaceViewModel
    let size: CGSize
    private var verticalSpacingValue: CGFloat { size.width / 377 * 15 }

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: verticalSpacingValue) {
                ForEach(viewModel.playlists, id: \.playlistID) { playlist in
                    PlakeListCell(viewModel: viewModel, playlist: playlist, size: size)
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

private struct PlakeListCell: View {
    @Environment(PlakeCoordinator.self) private var plakeCoord
    let viewModel: CollectionPlaceViewModel
    let playlist: PlaylistModel
    let size: CGSize
    private var imageHeight: CGFloat { (size.width - 20) * 157 / 341 }

    var body: some View {
        Button {
            viewModel.simpleHaptic()
            plakeCoord.dismissSheet()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                plakeCoord.push(route: .playlistView(viewModel: .init(playlist: playlist)))
            }
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                KFImage(URL(string: playlist.photoURL))
                    .resizable()
                    .cancelOnDisappear(true)
                    .placeholder {
                        Image(.sologPlaceholder)
                    }
                    .scaledToFill()
                    .frame(height: imageHeight)
                    .clipped()
                    .padding(.vertical, 15)

                Text(playlist.playlistName)
                    .font(.sCoreDream(weight: .dream5, size: 20))
                    .foregroundStyle(Color(.sTitleText))

                Divider()
                    .frame(height: 0.5)
                    .foregroundStyle(Color(.sLine))
                    .padding(.bottom, 6)

                HStack(spacing: 0) {
                    Text(Image(systemName: "music.note"))
                        .font(.system(size: 15))
                        .foregroundStyle(Color(.sSubHead))
                        .padding(.trailing, 2)
                    Text("수집한 음악")
                        .font(.notoSansKR(weight: .regular400, size: 15))
                        .foregroundStyle(Color(.sSubHead))
                        .padding(.trailing, 8)
                    Text("\(playlist.songs.count)곡")
                        .font(.notoSansKR(weight: .medium500, size: 15))
                        .foregroundStyle(Color(.sTitleText))
                }

                Divider()
                    .frame(height: 0.5)
                    .foregroundStyle(Color(.sLine))
                    .padding(.vertical, 6)

                Text("\(viewModel.formatDateToString(playlist.generationTime))")
                    .font(.notoSansKR(weight: .regular400, size: 12))
                    .foregroundStyle(Color(.sFootNote))
                    .padding(.bottom, 10)
            }
            .padding(.horizontal, 10)
            .background(Color(.sWhite))
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .shadow(color: Color(.sBlack).opacity(0.15), radius: 3, x: 0, y: 1)
        }
    }
}
