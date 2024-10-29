//
//  ArchiveListView.swift
//  AGAMI
//
//  Created by 박현수 on 10/14/24.
//

import SwiftUI
import Lottie

struct ArchiveListView: View {
    @State var viewModel: ArchiveListViewModel = ArchiveListViewModel()

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ArchiveListHeader(viewModel: viewModel)
                ArchiveSearchBar(viewModel: viewModel)
                GeometryReader { proxy in
                    ArchiveList(viewModel: viewModel, size: proxy.size)
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
        .confirmationDialog("", isPresented: $viewModel.isDialogPresented) {
            ConfirmationDialogActions(viewModel: viewModel)
        }
        .onOpenURL { url in
            if let redirectURL = Bundle.main.object(forInfoDictionaryKey: "REDIRECT_URL") as? String,
               let decodedRedirectURL = redirectURL.removingPercentEncoding {
                if url.absoluteString.contains(decodedRedirectURL) {
                    viewModel.exportingState = .none
                }
            }
        }
    }
}

private struct ArchiveListHeader: View {
    var viewModel: ArchiveListViewModel

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            Image(.archiveLogo)
            Spacer()
            Button {
                viewModel.isDialogPresented = true
            } label: {
                Image(.mypageIcon)
            }
        }
        .padding(EdgeInsets(top: 24, leading: 24, bottom: 12, trailing: 20))
    }
}

private struct ArchiveSearchBar: View {
    @Bindable var viewModel: ArchiveListViewModel
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

private struct ArchiveList: View {
    @Bindable var viewModel: ArchiveListViewModel
    let size: CGSize
    var verticalSpacingValue: CGFloat {
        size.width / 377 * 12
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: verticalSpacingValue) {
                ForEach(viewModel.playlists, id: \.playlistID) { playlist in
                    ArchiveListCell(
                        viewModel: viewModel,
                        playlist: playlist,
                        size: size
                    )
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

private struct ArchiveListCell: View {
    @Environment(ArchiveCoordinator.self) private var coord
    @State private var asyncImageOpacity: Double = 0

    let viewModel: ArchiveListViewModel
    let playlist: PlaylistModel
    let size: CGSize
    var verticalSize: CGFloat { size.width * 176 / 377 }

    var body: some View {
        Button {
            coord.push(view: .playlistView(viewModel: .init(playlist: playlist)))
        } label: {
            ZStack {
                AsyncImage(url: URL(string: playlist.photoURL)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .clipped()
                        .opacity(asyncImageOpacity)
                        .background(Color(.pGray1))
                        .onAppear {
                            withAnimation(.easeOut(duration: 1)) {
                                asyncImageOpacity = 1
                            }
                        }
                        .onDisappear {
                            asyncImageOpacity = 0
                        }
                } placeholder: {
                    Image(.archiveCellPlaceholder)
                }
                .frame(width: size.width, height: verticalSize)
                .shadow(radius: 10, x: 2, y: 4)

                Image(.archiveCellOverlay)
                    .resizable()

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

private struct ConfirmationDialogActions: View {
    var viewModel: ArchiveListViewModel

    var body: some View {
        Button("로그아웃", role: .destructive) {
            viewModel.logout()
        }
        Button("취소", role: .cancel) { }
    }
}

private struct ContextMenuItems: View {
    @Environment(\.openURL) private var openURL
    var viewModel: ArchiveListViewModel
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
