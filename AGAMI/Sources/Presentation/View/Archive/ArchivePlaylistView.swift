//
//  ArchivePlaylistView.swift
//  AGAMI
//
//  Created by 박현수 on 10/15/24.
//

import SwiftUI

struct ArchivePlaylistView: View {
    @State var viewModel: ArchivePlaylistViewModel
    @Environment(\.openURL) var openURL

    var body: some View {
        ZStack {
            List {
                ImageAndTitleWithHeaderView(viewModel: viewModel)
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden, edges: .top)
                ForEach(viewModel.playlist.songs, id: \.songID) { song in
                    PlaylistRow(song: song)
                }
                .onDelete(perform: viewModel.deleteMusic)
                .onMove(perform: viewModel.moveMusic)
            }
            .listStyle(.plain)
            .blur(radius: viewModel.isExporting ? 10 : 0)

            if viewModel.isExporting {
                ProgressView()
            }
        }
        .toolbarVisibilityForVersion(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                TopBarTrailingItems(viewModel: viewModel)
            }
        }
        .navigationTitle("플라키브")
    }
}

private struct ImageAndTitleWithHeaderView: View {
    let viewModel: ArchivePlaylistViewModel
    @State private var asyncImageOpacity: Double = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .bottom) {
                AsyncImage(url: URL(string: viewModel.playlist.photoURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
//                        .shadow(color: .black.opacity(0.25), radius: 10)
                        .opacity(asyncImageOpacity)
                        .onAppear {
                            withAnimation(.easeOut(duration: 1)) {
                                asyncImageOpacity = 1
                            }
                        }
                } placeholder: {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.white)
                        .aspectRatio(1, contentMode: .fit)
                }

                VStack(spacing: 0) {
                    Group {
                        Text(viewModel.playlist.streetAddress)
                            .padding(.bottom, 12)
                        Text(viewModel.formatDateToString(viewModel.playlist.generationTime))
                            .padding(.bottom, 22)
                    }
                    .font(.pretendard(weight: .medium500, size: 20))
                    .foregroundStyle(Color(.pWhite))
                }
            }
            .padding(EdgeInsets(top: 20, leading: 8, bottom: 0, trailing: 8))
            .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 4)

            Text(viewModel.playlist.playlistName)
                .font(.pretendard(weight: .bold700, size: 26))
                .multilineTextAlignment(.leading)
                .foregroundStyle(Color(.pBlack))
                .padding(EdgeInsets(top: 30, leading: 16, bottom: 0, trailing: 0))

            HStack(alignment: .bottom, spacing: 0) {
                Text("수집한 플레이크")
                    .font(.pretendard(weight: .semiBold600, size: 20))
                    .foregroundStyle(Color(.pBlack))
                Spacer()
                Text("\(viewModel.playlist.songs.count) 플레이크")
                    .font(.pretendard(weight: .medium500, size: 16))
                    .foregroundStyle(Color(.pPrimary))
            }
            .padding(EdgeInsets(top: 49, leading: 16, bottom: 16, trailing: 16))
        }
    }
}

private struct PlaylistContentsView: View {
    @Environment(ArchiveCoordinator.self) private var coord
    @Bindable var viewModel: ArchivePlaylistViewModel

    var body: some View {
        HStack {
            Text(viewModel.playlist.playlistName)
                .font(.system(size: 24, weight: .semibold))
            Spacer()
        }
        .padding(EdgeInsets(top: 32, leading: 24, bottom: 0, trailing: 24))

        TextEditor(text: $viewModel.playlist.playlistDescription)
            .font(.system(size: 17))
            .scrollContentBackground(.hidden)
            .foregroundStyle(.black)
            .padding(12)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(EdgeInsets(top: 22, leading: 24, bottom: 22, trailing: 24))

        Button {
            coord.push(view: .detailView(viewModel: viewModel))
        } label: {
            Text("플레이크 리스트 보기")
                .font(.system(size: 17))
                .padding(.vertical, 10)
        }
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(EdgeInsets(top: 0, leading: 24, bottom: 40, trailing: 24))
        Spacer()
    }
}

private struct TopBarTrailingItems: View {
    var viewModel: ArchivePlaylistViewModel

    var body: some View {
        HStack {
            Button("편집") {
                viewModel.isEditing.toggle()
            }
            Menu {
                MenuContents(viewModel: viewModel)
            } label: {
                Image(systemName: "ellipsis.circle")
            }

        }
    }
}

private struct MenuContents: View {
    var viewModel: ArchivePlaylistViewModel

    var body: some View {
        Button {

        } label: {
            Label("공유하기", systemImage: "square.and.arrow.up")
        }

        Button(role: .destructive) {

        } label: {
            Label("삭제하기", systemImage: "trash")
        }
    }
}
