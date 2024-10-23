//
//  ArchiveListView.swift
//  AGAMI
//
//  Created by 박현수 on 10/14/24.
//

import SwiftUI

struct ArchiveListView: View {
    @State var viewModel: ArchiveListViewModel = ArchiveListViewModel()

    var body: some View {
        ArchiveListHeader(viewModel: viewModel)
        GeometryReader {
            let size = $0.size

            ArchiveList(
                viewModel: viewModel,
                size: size
            )
        }
        .safeAreaPadding(.horizontal, 16)
        .onAppear {
            viewModel.fetchPlaylists()
        }
        .toolbarBackground(.visible, for: .tabBar)
        .confirmationDialog("", isPresented: $viewModel.isDialogPresented) {
            ConfirmationDialogActions(viewModel: viewModel)
        }
    }
}

private struct ArchiveListHeader: View {
    var viewModel: ArchiveListViewModel

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .bottom, spacing: 0) {
                Image(.archiveLogo)
                Spacer()
                Button {
                    viewModel.isDialogPresented = true
                } label: {
                    Image(.mypageIcon)
                }
            }
            .padding(
                EdgeInsets(
                    top: 24,
                    leading: 24,
                    bottom: 12,
                    trailing: 20
                )
            )
            ArchiveSearchBar(viewModel: viewModel)
        }
    }
}

private struct ArchiveSearchBar: View {
    @Bindable var viewModel: ArchiveListViewModel
    @FocusState var isFocused: Bool

    var body: some View {
        ZStack {
            TextField("당신의 아카이브", text: $viewModel.searchText)
                .padding(
                    EdgeInsets(
                        top: 10,
                        leading: 12,
                        bottom: 10,
                        trailing: 12
                    )
                )
                .focused($isFocused)
                .background(Color(rgbaHex: "#DDDDDF99"))
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
                        .foregroundColor(Color(rgbaHex: "#88888AB2"))
                        .padding(.trailing, 20)
                }
            }
        }
    }
}

private struct ArchiveList: View {
    @Bindable var viewModel: ArchiveListViewModel
    let size: CGSize

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 12) {
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
        .scrollTargetBehavior(.viewAligned(limitBehavior: .always))
        .safeAreaPadding(.vertical, size.height / 10)
    }
}

private struct ArchiveListCell: View {
    @Environment(ArchiveCoordinator.self) private var coord

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
                } placeholder: {
                    Rectangle()
                        .fill(.white)
                }
                .frame(width: size.width, height: verticalSize)
                .shadow(radius: 10, x: 2, y: 4)
                Image(.archiveCellOverlay)
                    .resizable()
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

private struct ConfirmationDialogActions: View {
    var viewModel: ArchiveListViewModel
    var body: some View {
        Button("로그아웃", role: .destructive) {
            viewModel.logout()
        }
    }
}
