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
            List {
                PlaylistCoverImageView(viewModel: viewModel)
                    .onTapGesture {
                        if viewModel.photoUIImage == nil {
                            coordinator.push(view: .cameraView(viewModel: viewModel))
                        } else {
                            viewModel.showSheet.toggle()
                        }
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(.zero)
                
                PlaylistTitleTextField(viewModel: viewModel)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 8)
                    .listRowSeparator(.hidden)
                    .listRowInsets(.zero)
                
                PlaylistSongListHeader(viewModel: viewModel)
                    .padding(.top, 28)
                    .padding(.horizontal, 24)
                    .listRowSeparator(.hidden)
                    .listRowInsets(.zero)
                
                PlaylistSongList(viewModel: viewModel)
                    .padding(.top, 10)
                    .padding(.horizontal, 8)
                    .listRowInsets(.zero)
                
                PlaylistDescriptionTextField(viewModel: viewModel)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 13)
                    .listRowSeparator(.hidden)
                    .listRowInsets(.zero)
                    .padding(.bottom, 56)
            }
            
            if viewModel.isSaving {
                ProgressView("저장 중입니다...")
                    .padding()
            }
        }
        .confirmationDialog("", isPresented: $viewModel.showSheet) {
            Button("다시 찍기") {
                coordinator.push(view: .cameraView(viewModel: viewModel))
            }
            Button("기본 이미지로 변경", role: .destructive) {
                viewModel.photoUIImage = nil
            }
            Button("취소", role: .cancel) {}
        }
        .onTapGesture {
            hideKeyboard()
        }
        .listStyle(PlainListStyle())
        .scrollDisabled(viewModel.isSaving)
        .allowsHitTesting(!viewModel.isSaving)
        .navigationTitle("플리카빙")
        .navigationBarTitleDisplayMode(.inline)
        .scrollIndicators(.hidden)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task {
                        if await viewModel.savedPlaylist() {
                            viewModel.clearDiggingList()
                            coordinator.popToRoot()
                        } else {
                            print("Failed to save playlist. Please try again.")
                        }
                    }
                } label: {
                    Text("저장")
                        .font(.pretendard(weight: .semiBold600, size: 17))
                }
                .disabled(viewModel.diggingList.isEmpty || viewModel.isSaving)
            }
        }
        .toolbarRole(.editor)
        .toolbarVisibilityForVersion(.hidden, for: .tabBar)
    }
}

private struct PlaylistCoverImageView: View {
    var viewModel: SearchWritingViewModel
    
    var body: some View {
        HStack(spacing: 0) {
            Spacer()
            if let uiImage = viewModel.photoUIImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: 277, height: 277)
                    .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 4)
                    .overlay(alignment: .bottom) {
                        VStack(spacing: 0) {
                            Text("\(viewModel.currentRegion), \(viewModel.currentLocality)")
                                .font(.pretendard(weight: .medium500, size: 14))
                                .foregroundStyle(Color(.pWhite))
                            
                            Text(viewModel.currentDate)
                                .font(.pretendard(weight: .medium500, size: 14))
                                .foregroundStyle(Color(.pWhite))
                                .padding(.top, 4)
                        }
                        .padding(.bottom, 16)
                    }
            } else {
                Image(.basicCover)
                    .resizable()
                    .clipShape(RoundedRectangle(cornerRadius: 13))
                    .frame(width: 277, height: 277)
                    .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 4)
                    .overlay {
                        HStack(spacing: 0) {
                            Image(systemName: "photo.fill")
                                .font(.system(size: 17, weight: .regular))
                                .foregroundStyle(Color(.pPrimary))
                            
                            Text("커버 설정하기")
                                .font(.pretendard(weight: .semiBold600, size: 20))
                                .foregroundStyle(Color(.pPrimary))
                                .padding(.leading, 5)
                        }
                    }
            }
            Spacer()
        }
        .padding(.vertical, 18)
    }
}

private struct PlaylistTitleTextField: View {
    @Bindable var viewModel: SearchWritingViewModel
    @FocusState var isFocused: Bool
    
    var body: some View {
        TextField("\(viewModel.placeHolderAddress)에서 만난 플레이크", text: $viewModel.userTitle)
            .font(.pretendard(weight: .semiBold600, size: 24))
            .foregroundStyle(.black)
            .focused($isFocused)
            .padding(EdgeInsets(top: 15, leading: 16, bottom: 15, trailing: 8))
            .background(Color(.pLightGray))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(.pPrimary), lineWidth: isFocused ? 1 : 0)
            }
    }
}

private struct PlaylistSongListHeader: View {
    var viewModel: SearchWritingViewModel
    
    var body: some View {
        HStack(spacing: 0) {
            Text("수집한 플레이크")
                .font(.pretendard(weight: .semiBold600, size: 20))
                .foregroundStyle(Color(.pBlack))
            Spacer()
            Text("\(viewModel.diggingList.count) 플레이크")
                .font(.pretendard(weight: .medium500, size: 16))
                .foregroundStyle(Color(.pPrimary))
        }
    }
}

private struct PlaylistSongList: View {
    var viewModel: SearchWritingViewModel
    
    var body: some View {
        ForEach(viewModel.diggingList, id: \.songID) { song in
            PlaylistRow(song: song)
        }
        .listRowInsets(.init(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)))
    }
}

private struct PlaylistDescriptionTextField: View {
    @Bindable var viewModel: SearchWritingViewModel
    @FocusState var isFocused: Bool
    
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .foregroundStyle(Color(.pLightGray))
            .overlay(alignment: .topLeading) {
                TextField("플레이크에 대한 설명 추가하기", text: $viewModel.userDescription, axis: .vertical)
                    .background(.clear)
                    .foregroundStyle(.black)
                    .padding()
            }
            .frame(height: 65)
    }
}
