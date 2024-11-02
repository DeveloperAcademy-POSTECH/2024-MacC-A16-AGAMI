//
//  SearchStartView.swift
//  AGAMI
//
//  Created by Seoyeon Choi on 10/15/24.
//

import SwiftUI

struct SearchStartView: View {
    @Environment(PlakeCoordinator.self) private var coordinator
    @State private var viewModel: SearchStartViewModel = SearchStartViewModel()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color(.pLightGray)
                .ignoresSafeArea()
            
            List {
                SearchPlakeTitleTextField(viewModel: viewModel)
                    .listRowSeparator(.hidden)
                    .listRowInsets(.zero)
                    .listRowBackground(Color(.pLightGray))
                    .padding(.top, 36)
                
                SearchSongListHeader(viewModel: viewModel)
                    .listRowSeparator(.hidden)
                    .listRowInsets(.zero)
                    .listRowBackground(Color(.pLightGray))
                
                SearchPlakeSongList(viewModel: viewModel)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 2, trailing: 0))
                
                Spacer()
                    .listRowSeparator(.hidden)
                    .frame(height: 50)
                    .listRowBackground(Color(.pLightGray))
            }
            .listStyle(.plain)
            .scrollIndicators(.hidden)
            
            ZStack(alignment: .bottom) {
                Button {
                    coordinator.push(view: .searchShazamingView)
                } label: {
                    PlakeCTAButton(type: .addSong)
                        .padding(.bottom, 26)
                }
            }
            .frame(height: 47)
            .background(Color(.pLightGray))
        }
        .onAppear {
            viewModel.loadSavedSongs()
        }
        .navigationTitle("새로운 플레이크")
        .navigationBarTitleDisplayMode(.large)
        .toolbarVisibilityForVersion(.hidden, for: .tabBar)
        .toolbarRole(.editor)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    coordinator.push(view: .searchWritingView)
                } label: {
                    Text("다음")
                        .font(.pretendard(weight: .medium500, size: 17))
                }
                .disabled(viewModel.diggingList.isEmpty || !viewModel.isLoaded)
            }
        }
    }
}

private struct SearchPlakeTitleTextField: View {
    @Bindable var viewModel: SearchStartViewModel
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("플레이크 타이틀")
                .font(.pretendard(weight: .semiBold600, size: 20))
                .foregroundStyle(Color(.pBlack))
                .padding(.leading, 16)
                .padding(.bottom, 14)
            
            TextField("\(viewModel.placeHolderAddress)", text: $viewModel.userTitle)
                .font(.pretendard(weight: .medium500, size: 20))
                .foregroundStyle(.black)
                .focused($isFocused)
                .padding(16)
                .background(Color(.pWhite))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(.pPrimary), lineWidth: isFocused ? 1 : 0)
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 37)
        }
    }
}

private struct SearchSongListHeader: View {
    var viewModel: SearchStartViewModel
    
    var body: some View {
        HStack(spacing: 0) {
            Text("수집한 노래")
                .font(.pretendard(weight: .semiBold600, size: 20))
                .foregroundStyle(Color(.pBlack))
            
            Spacer()
            
            Text("\(viewModel.diggingList.count)곡")
                .font(.pretendard(weight: .medium500, size: 16))
                .foregroundStyle(Color(.pPrimary))
        }
        .padding(.horizontal, 16)
    }
}

private struct SearchPlakeSongList: View {
    var viewModel: SearchStartViewModel
    
    var body: some View {
        ForEach(viewModel.diggingList, id: \.songID) { song in
            PlaylistRow(song: song)
        }
        .onDelete(perform: viewModel.deleteSong)
        .onMove(perform: viewModel.moveSong)
        .padding(.horizontal, 8)
    }
}

#Preview {
    SearchStartView()
}
