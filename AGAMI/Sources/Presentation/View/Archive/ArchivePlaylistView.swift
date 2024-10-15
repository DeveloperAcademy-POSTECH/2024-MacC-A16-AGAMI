//
//  ArchivePlaylistView.swift
//  AGAMI
//
//  Created by 박현수 on 10/15/24.
//

import SwiftUI

struct ArchivePlaylistView: View {
    @State var viewModel: ArchivePlaylistViewModel = ArchivePlaylistViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                PlaylistImageCellView(viewModel: viewModel)
                TitleAndDescriptionView(viewModel: viewModel)
                PlaylistView(viewModel: viewModel)
            }
            .toolbar { EditButton() }
        }

    }
}

private struct PlaylistImageCellView: View {
    let viewModel: ArchivePlaylistViewModel

    var body: some View {
        AsyncImage(url: viewModel.dummyURL) { image in
            image
                .resizable()
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .aspectRatio(1, contentMode: .fit)
                .padding(.horizontal, 20)
                .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 4)
        } placeholder: {
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
                .aspectRatio(1, contentMode: .fit)
                .padding(.horizontal, 20)
                .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 4)
        }
        .padding(.top, 20)
    }
}

private struct TitleAndDescriptionView: View {
    let viewModel: ArchivePlaylistViewModel

    var body: some View {
        HStack {
            Text(viewModel.playlistTitle)
                .font(.system(size: 32, weight: .bold))
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 40)

        Text(viewModel.playlistDescription)
            .font(.system(size: 15))
            .foregroundStyle(.gray)
            .padding(10)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal, 16)
            .padding(.top, 16)
    }
}

private struct PlaylistView: View {
    @Bindable var viewModel: ArchivePlaylistViewModel

    var body: some View {
        HStack {
            Text("플레이리스트")
                .font(.system(size: 20, weight: .semibold))
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 28)

        Divider()
            .padding(.top, 10)

        List {
            ForEach(viewModel.dummyPlaylist) { song in
                HStack {
                    AsyncImage(url: song.imageURL) { image in
                        image
                            .resizable()
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 16))

                    } placeholder: {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.black)
                            .frame(width: 60, height: 60)
                    }
                    .padding(.trailing, 10)

                    VStack(alignment: .leading) {
                        Text(song.title)
                            .font(.system(size: 20))
                        Text(song.artist)
                            .font(.system(size: 16))
                            .foregroundStyle(.gray)
                    }
                }
            }
            .onDelete(perform: viewModel.deleteMusic)
            .onMove(perform: viewModel.moveMusic)
        }
        .listStyle(.plain)
        .scaledToFit()
    }
}

#Preview {
    ArchivePlaylistView()
}
