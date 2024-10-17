//
//  SearchPlaylistModalView.swift
//  AGAMI
//
//  Created by Seoyeon Choi on 10/16/24.
//

import SwiftUI

struct SearchPlaylistModalView: View {
    @Bindable var viewModel: SearchStartViewModel
    var navigationTitle: String
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Section(header: HStack {
                    Text("\(viewModel.diggingList.count) 플레이크")
                        .font(.system(size: 16, weight: .semibold))
                        .kerning(0.4)
                        .padding(.vertical, 13)
                        .padding(.leading, 16)
                    Spacer()
                }) {
                    List {
                        ForEach(viewModel.diggingList) { song in
                            PlaylistRow(song: song)
                        }
                        .onDelete(perform: viewModel.deleteSong)
                        .onMove(perform: viewModel.moveSong)
                    }
                    .scrollIndicators(.hidden)
                }
            }
            .navigationTitle(navigationTitle)
        }
        .onDisappear {
            viewModel.stopRecognition()
        }
    }
}

#Preview {
    SearchPlaylistModalView(viewModel: SearchStartViewModel(), navigationTitle: "구리스")
}
