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
        GeometryReader {
            let size = $0.size
            
            ArchiveList(
                viewModel: viewModel,
                size: size
            )
        }
        .safeAreaPadding(.horizontal, 16)
        .searchable(
            text: $viewModel.searchText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: ""
        )
        .onAppear {
            viewModel.fetchPlaylists()
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
    var verticalSize: CGFloat { size.width / 2 }

    var body: some View {
        Button {
            coord.push(view: .playlistView(viewModel: .init(playlist: playlist)))
        } label: {
            AsyncImage(url: URL(string: playlist.photoURL)) { image in
                image
                    .resizable()
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            } placeholder: {
                Rectangle()
                    .fill(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .frame(width: size.width, height: verticalSize)
            .shadow(radius: 10, x: 2, y: 4)
        }
    }
}

#Preview {
    ArchiveListView()
        .environment(ArchiveCoordinator())
}
