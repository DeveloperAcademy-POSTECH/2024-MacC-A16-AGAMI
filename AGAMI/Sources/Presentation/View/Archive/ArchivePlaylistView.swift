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
        VStack(spacing: 0) {
            PlaylistImageCellView(viewModel: viewModel)
            PlaylistContentsView(viewModel: viewModel)
        }
        .toolbarVisibilityForVersion(.hidden, for: .tabBar)
    }
}

private struct PlaylistImageCellView: View {
    let viewModel: ArchivePlaylistViewModel
    
    var body: some View {
        AsyncImage(url: URL(string: viewModel.dummyURL)) { image in
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

private struct PlaylistContentsView: View {
    @Environment(ArchiveCoordinator.self) private var coord
    @Bindable var viewModel: ArchivePlaylistViewModel

    var body: some View {
        HStack {
            Text(viewModel.playlistTitle)
                .font(.system(size: 24, weight: .semibold))
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 32)

        TextEditor(text: $viewModel.playlistDescription)
            .font(.system(size: 17))
            .scrollContentBackground(.hidden)
            .foregroundStyle(.black)
            .padding(12)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal, 24)
            .padding(.vertical, 22)

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
        .padding(.horizontal, 24)
        .padding(.bottom, 40)
        Spacer()
    }
}
