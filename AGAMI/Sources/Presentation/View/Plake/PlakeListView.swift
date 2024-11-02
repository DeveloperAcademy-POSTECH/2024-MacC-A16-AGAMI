//
//  ArchiveListView.swift
//  AGAMI
//
//  Created by 박현수 on 10/14/24.
//

import SwiftUI
import Kingfisher

struct PlakeListView: View {
    @State var viewModel: PlakeListViewModel = PlakeListViewModel()

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ListHeader(viewModel: viewModel)
                SearchBar(viewModel: viewModel)
                GeometryReader { proxy in
                    ListView(viewModel: viewModel, size: proxy.size)
                }
                .safeAreaPadding(.horizontal, 16)
            }
            switch viewModel.exportingState {
            case .isAppleMusicExporting:
                AppleMusicLottieView()
            case .isSpotifyExporting:
                SpotifyLottieView()
            case .none:
                EmptyView()
            }
        }
        .onAppear {
            viewModel.fetchPlaylists()
        }
        .toolbarBackground(.visible, for: .tabBar)
        .onTapGesture {
            hideKeyboard()
        }
        .onOpenURL { url in
            viewModel.handleURL(url)
        }
    }
}

private struct ListHeader: View {
    @Environment(PlakeCoordinator.self) private var coordinator
    let viewModel: PlakeListViewModel

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            Image(.plakeTabLogo)
            Spacer()
            Button {
                coordinator.push(view: .newPlakeView)
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "plus.circle.fill")
                        .renderingMode(.template)
                        .font(.system(size: 18))
                    Text("새로운 플레이크")
                        .font(.pretendard(weight: .medium500, size: 18))
                }
            }
        }
        .padding(EdgeInsets(top: 24, leading: 16, bottom: 12, trailing: 16))
    }
}

private struct SearchBar: View {
    @Bindable var viewModel: PlakeListViewModel
    @FocusState var isFocused: Bool

    var body: some View {
        ZStack {
            TextField("당신의 아카이브", text: $viewModel.searchText)
                .padding(EdgeInsets(top: 10, leading: 12, bottom: 10, trailing: 12))
                .focused($isFocused)
                .background(Color(.pGray2))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.accentColor, lineWidth: isFocused ? 1 : 0)
                )
                .padding(.horizontal, 8)
                .padding(.vertical, 8)

            HStack {
                Spacer()
                Button {
                    if isFocused {
                        viewModel.clearSearchText()
                        isFocused = false
                    }
                } label: {
                    Image(systemName: isFocused ? "x.circle.fill" : "magnifyingglass")
                        .foregroundStyle(Color(.pGray1))
                        .padding(.trailing, 20)
                }
            }
        }
    }
}

private struct ListView: View {
    @Bindable var viewModel: PlakeListViewModel
    let size: CGSize
    private var verticalSpacingValue: CGFloat {
        size.width / 377 * 12
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: verticalSpacingValue) {
                Group {
                    if viewModel.playlists.isEmpty {
                        MakeNewPlakeCell(size: size)
                    }
                    ForEach(viewModel.playlists, id: \.playlistID) { playlist in
                        PlakeListCell(
                            viewModel: viewModel,
                            playlist: playlist,
                            size: size
                        )
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
        .safeAreaPadding(.vertical, size.height / 10)
    }
}

private struct PlakeListCell: View {
    @Environment(PlakeCoordinator.self) private var coord
    @State private var kfImageOpacity: Double = 0

    let viewModel: PlakeListViewModel
    let playlist: PlaylistModel
    let size: CGSize
    private var verticalSize: CGFloat { size.width * 176 / 377 }

    var body: some View {
        Button {
            coord.push(route: .playlistView(viewModel: .init(playlist: playlist)))
        } label: {
            ZStack {
                KFImage(URL(string: playlist.photoURL))
                    .resizable()
                    .cancelOnDisappear(true)
                    .placeholder {
                        Image(.archiveCellPlaceholder)
                    }
                    .scaledToFill()
                    .clipped()
                    .opacity(kfImageOpacity)
                    .background(Color(.pGray1))
                    .frame(width: size.width, height: verticalSize)
                    .shadow(radius: 10, x: 2, y: 4)
                    .onAppear {
                        withAnimation(.easeOut(duration: 1)) {
                            kfImageOpacity = 1
                        }
                    }
                    .onDisappear {
                        kfImageOpacity = 0
                    }

                VStack(alignment: .leading, spacing: 0) {
                    Group {
                        Text(playlist.playlistName)
                            .font(.pretendard(weight: .bold700, size: 22))
                            .kerning(-0.5)
                            .padding(EdgeInsets(top: 22, leading: 16, bottom: 0, trailing: 0))
                        Text(playlist.streetAddress)
                            .font(.pretendard(weight: .medium500, size: 16))
                            .kerning(-0.5)
                            .padding(EdgeInsets(top: 14, leading: 18, bottom: 0, trailing: 0))
                    }
                    .foregroundStyle(Color(.pWhite))
                    .shadow(radius: 10)

                    Spacer()

                    HStack(spacing: 0) {

                        Spacer()
                        Text(viewModel.formatDateToString(playlist.generationTime))
                            .font(.pretendard(weight: .regular400, size: 14))
                            .foregroundStyle(Color(.pWhite))
                            .kerning(-0.5)
                            .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                            .background(Color(.pGray1))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 12))
                    }
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .contextMenu {
            ContextMenuItems(viewModel: viewModel, playlist: playlist)
        }
    }
}

private struct MakeNewPlakeCell: View {
    @Environment(PlakeCoordinator.self) private var coordinator
    let size: CGSize
    private var verticalSize: CGFloat { size.width * 176 / 377 }
    var body: some View {
        Button {
            coordinator.push(view: .newPlakeView)
        } label: {
            ZStack {
                Image(.makeNewPlakeCell)
                    .resizable()
                VStack {
                    HStack {
                        Text("새로운 플레이크를 디깅해보세요")
                            .font(.pretendard(weight: .bold700, size: 22))
                            .kerning(-0.5)
                            .padding(EdgeInsets(top: 22, leading: 16, bottom: 0, trailing: 0))
                            .foregroundStyle(Color(.pWhite))
                        Spacer()
                    }
                    Spacer()
                }
            }
        }
        .frame(width: size.width, height: verticalSize)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 10, x: 2, y: 4)
    }
}

private struct ContextMenuItems: View {
    @Environment(\.openURL) private var openURL
    let viewModel: PlakeListViewModel
    let playlist: PlaylistModel

    var body: some View {
        Button {
            Task {
                if let appleMusicURL = await viewModel.exportPlaylistToAppleMusic(playlist: playlist) {
                    openURL(appleMusicURL)
                }
            }
        } label: {
            Label("Apple Music에서 열기", systemImage: "square.and.arrow.up")
        }
        Button {
            viewModel.exportPlaylistToSpotify(playlist: playlist) { result in
                switch result {
                case .success(let url):
                    openURL(url)
                case .failure(let err):
                    dump(err.localizedDescription)
                }
            }
        } label: {
            Label("Spotify에서 열기", systemImage: "square.and.arrow.up")
        }
        Button(role: .destructive) {
            viewModel.deletePlaylist(playlistID: playlist.playlistID)
        } label: {
            Label("삭제", systemImage: "trash")
        }
    }
}
