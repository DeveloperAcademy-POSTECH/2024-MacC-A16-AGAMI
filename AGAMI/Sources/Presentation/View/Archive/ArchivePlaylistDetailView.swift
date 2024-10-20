//
//  ArchivePlaylistSheetView.swift
//  AGAMI
//
//  Created by 박현수 on 10/18/24.
//

import SwiftUI

struct ArchivePlaylistDetailView: View {
    var viewModel: ArchivePlaylistViewModel

    var body: some View {
        VStack(spacing: 0) {
            Text(viewModel.playlist.playlistName)
                .font(.system(size: 20, weight: .semibold))
                .padding(.vertical, 11)
            List {
                ForEach(viewModel.playlist.songs, id: \.songID) { song in
                    PlaylistRow(song: song)
                }
                .onDelete(perform: viewModel.deleteMusic)
                .onMove(perform: viewModel.moveMusic)
            }
            .listStyle(.plain)
        }
        .toolbarVisibilityForVersion(.hidden, for: .tabBar)
    }
}

// #Preview {
//     ArchivePlaylistDetailView(viewModel: ArchivePlaylistViewModel())
// }
