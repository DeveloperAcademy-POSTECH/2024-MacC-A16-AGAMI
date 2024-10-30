//
//  SearchDiggingListModalView.swift
//  AGAMI
//
//  Created by Seoyeon Choi on 10/16/24.
//

import SwiftUI

struct SearchDiggingListModalView: View {
    @Environment(SearchCoordinator.self) var coordinator
    var viewModel: SearchStartViewModel
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Text("플레이크 리스트")
                        .font(.pretendard(weight: .bold700, size: 30))
                        .foregroundStyle(Color(.pBlack))
                    
                    Spacer()
                    
                    Button {
                        coordinator.push(view: .writingView)
                        coordinator.dismissSheet()
                        viewModel.shazamStatus = .idle
                    } label: {
                        Image(.nextButton)
                            .resizable()
                            .frame(width: 34, height: 34)
                    }
                }
                .padding(.top, 42)
                .padding(.horizontal, 24)
                
                Section(header: HStack(spacing: 0) {
                    Text("\(viewModel.diggingList.count) 플레이크")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color(.pBlack))
                        .padding(EdgeInsets(top: 34, leading: 24, bottom: 13, trailing: 0))
                    Spacer()
                }) {
                    List {
                        ForEach(viewModel.diggingList, id: \.songID) { song in
                            PlaylistRow(song: song)
                        }
                        .onDelete(perform: viewModel.deleteSong)
                        .onMove(perform: viewModel.moveSong)
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 2, trailing: 0))
                    }
                    .scrollIndicators(.hidden)
                    .listStyle(InsetGroupedListStyle())
                }
            }
        }
        .onAppear {
            viewModel.loadSavedSongs()
        }
        .onDisappear {
            viewModel.stopRecognition()
        }
    }
}

#Preview {
    SearchDiggingListModalView(viewModel: SearchStartViewModel())
}
