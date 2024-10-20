//
//  SearchPlaylistModalView.swift
//  AGAMI
//
//  Created by Seoyeon Choi on 10/16/24.
//

import SwiftUI

struct SearchPlaylistModalView: View {
    @Environment(SearchCoordinator.self) var coordinator
    var viewModel: SearchStartViewModel
    
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
            .navigationTitle("플레이크 리스트")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing, content: {
                    Button(action: {
                        coordinator.dismissSheet()
                        coordinator.push(view: .writingView)
                    }, label: {
                        Text("Next")
                    })
                })
            }
        }
        .onDisappear {
            viewModel.stopRecognition()
        }
    }
}

#Preview {
    SearchPlaylistModalView(viewModel: SearchStartViewModel())
}
