//
//  SearchWritingView.swift
//  AGAMI
//
//  Created by Seoyeon Choi on 10/16/24.
//

import SwiftUI

struct SearchWritingView: View {
    @Environment(SearchCoordinator.self) var coordinator
    @State var viewModel: SearchWritingViewModel = SearchWritingViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            AsyncImage(url: URL(string: viewModel.photoUrl)) { image in
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
            .onTapGesture {
                coordinator.push(view: .cameraView(viewModel: viewModel))
            }
            
            VStack(alignment: .leading, spacing: 0) {
                TextField("타이틀을 입력하세요", text: $viewModel.userTitle)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 24)
                
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(.gray.opacity(0.2))
                    .overlay(alignment: .topLeading) {
                        TextField("텍스트 기록 남기기", text: $viewModel.userDescription, axis: .vertical)
                            .background(.clear)
                            .foregroundStyle(.black)
                            .padding()
                    }
                    .frame(height: 168)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 13)
            }
            
            Button {
                coordinator.presentFullScreenCover(.playlistFullscreenView(viewModel: viewModel))
            } label: {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(.gray.opacity(0.3))
                    .overlay {
                        Text("플리 목록 보기")
                    }
                    .frame(width: 260, height: 100)
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
        .navigationTitle("플리카빙")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task {
                        await viewModel.savedPlaylist()
                        viewModel.clearDiggingList()
                        coordinator.popToRoot()
                    }
                } label: {
                    Text("저장")
                }
            }
        }
    }
}
