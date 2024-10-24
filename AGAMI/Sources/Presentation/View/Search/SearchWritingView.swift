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
        ZStack {
            VStack(spacing: 0) {
                photoView
                
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
                            viewModel.showProgress()
                            await viewModel.savedPlaylist()
                            viewModel.clearDiggingList()
                            coordinator.popToRoot()
                            viewModel.hideProgress()
                        }
                    } label: {
                        Text("저장")
                    }
                }
            }
            .disabled(viewModel.isLoading)
            .blur(radius: viewModel.isLoading ? 10 : 0)
            
            if viewModel.isLoading {
                ProgressView()
                
            }
        }
    }
    
    @ViewBuilder
    var photoView: some View {
        if let uiImage = viewModel.photoUIIMage {
            coverImageView(image: Image(uiImage: uiImage))
        } else {
            coverImageView(image: Image(.photoPlaceHolder))
                .overlay {
                    HStack(spacing: 9) {
                        Image(systemName: "photo.fill")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 25.5535, height: 12.26568)
                            .foregroundColor(.accentColor)
                        Text("커버 설정하기")
                            .font(
                                .system(size: 20)
                                .weight(.semibold)
                            )
                            .foregroundColor(.accentColor)
                    }
                }
        }
    }
    
    func coverImageView(image: Image) -> some View {
        image
            .resizable()
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .aspectRatio(1, contentMode: .fit)
            .padding(.horizontal, 20)
            .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 4)
            .onTapGesture {
                coordinator.push(view: .cameraView(viewModel: viewModel))
            }
    }
}
