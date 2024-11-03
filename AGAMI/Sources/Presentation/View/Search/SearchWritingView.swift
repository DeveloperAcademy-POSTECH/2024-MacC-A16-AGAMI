//
//  SearchWritingView.swift
//  AGAMI
//
//  Created by Seoyeon Choi on 10/16/24.
//

import SwiftUI

import PhotosUI

struct SearchWritingView: View {
    @Environment(PlakeCoordinator.self) private var coordinator
    @State var viewModel: SearchWritingViewModel = SearchWritingViewModel()
    
    var body: some View {
        ZStack {
            Color(.pLightGray)
                .ignoresSafeArea()
            
            List {
                PlaylistCoverImageView(viewModel: viewModel)
                    .listRowSeparator(.hidden)
                    .listRowInsets(.zero)
                    .listRowBackground(Color(.pLightGray))
                
                PlaylistTitleTextField(viewModel: viewModel)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 8)
                    .listRowSeparator(.hidden)
                    .listRowInsets(.zero)
                    .listRowBackground(Color(.pLightGray))
                
                PlaylistSongListHeader(viewModel: viewModel)
                    .padding(EdgeInsets(top: 28, leading: 24, bottom: 10, trailing: 24))
                    .listRowSeparator(.hidden)
                    .listRowInsets(.zero)
                    .listRowBackground(Color(.pLightGray))
                
                PlaylistSongList(viewModel: viewModel)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 2, trailing: 0))
                
                PlaylistDescriptionTextField(viewModel: viewModel)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 13)
                    .listRowSeparator(.hidden)
                    .listRowInsets(.zero)
                    .listRowBackground(Color(.pLightGray))
                    .padding(.bottom, 56)
            }
            
            if viewModel.isSaving {
                ProgressView("저장 중입니다...")
                    .padding()
            }
            
        }
        .confirmationDialog("", isPresented: $viewModel.showSheet) {
            Button("카메라") {
                coordinator.push(route: .cameraView(viewModel: viewModel))
            }
            Button("앨범에서 가져오기") {
                viewModel.showPhotoPicker.toggle()
            }
            Button("기본 이미지로 변경", role: .destructive) {
                viewModel.photoUIImage = nil
            }
            Button("취소", role: .cancel) {}
        }
        .photosPicker(isPresented: $viewModel.showPhotoPicker,
                      selection: $viewModel.selectedItem)
        .onChange(of: viewModel.selectedItem) {
            Task {
                await viewModel.loadImageFromGallery()
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
        .listStyle(PlainListStyle())
        .scrollDisabled(viewModel.isSaving)
        .allowsHitTesting(!viewModel.isSaving)
        .navigationTitle("커버 사진")
        .navigationBarTitleDisplayMode(.large)
        .scrollIndicators(.hidden)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task {
                        if await viewModel.savedPlaylist() {
                            viewModel.clearDiggingList()
                            coordinator.popToRoot()
                            viewModel.isLoaded = false
                        } else {
                            print("Failed to save playlist. Please try again.")
                        }
                    }
                } label: {
                    Text("저장")
                        .font(.pretendard(weight: .semiBold600, size: 17))
                }
                .disabled(viewModel.diggingList.isEmpty || viewModel.isSaving || !viewModel.isLoaded)
            }
        }
        .toolbarRole(.editor)
        .toolbarVisibilityForVersion(.hidden, for: .tabBar)
    }
}

private struct PlaylistCoverImageView: View {
    let viewModel: SearchWritingViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("어떤 곳에서 만난 플레이크인가요?")
                .font(.pretendard(weight: .regular400, size: 16))
                .foregroundStyle(Color(.pGray1))
                .padding(.leading, 16)
            
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
                    Image(.coverImageThumbnail)
                        .resizable()
                        .clipShape(RoundedRectangle(cornerRadius: 13))
                        .frame(width: 277, height: 277)
                        .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 4)
                        .overlay {
                            HStack(spacing: 0) {
                                Image(systemName: "camera.viewfinder")
                                    .font(.system(size: 17, weight: .regular))
                                    .foregroundStyle(Color(.pPrimary))
                                
                                Text("사진으로 기록")
                                    .font(.pretendard(weight: .medium500, size: 20))
                                    .foregroundStyle(Color(.pPrimary))
                                    .padding(.leading, 5)
                            }
                        }
                }
                Spacer()
            }
            .highPriorityGesture(imageViewTapGesture())
            .padding(.vertical, 36)
        }
    }
    
    private func imageViewTapGesture() -> some Gesture {
        TapGesture().onEnded {
            viewModel.showSheet.toggle()
        }
    }
}

private struct PlaylistTitleTextField: View {
    @Bindable var viewModel: SearchWritingViewModel
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("플레이크 타이틀")
                .font(.pretendard(weight: .semiBold600, size: 20))
                .foregroundStyle(Color(.pBlack))
                .padding(EdgeInsets(top: 0, leading: 16, bottom: 14, trailing: 0))
            
            TextField("\(viewModel.placeHolderAddress)", text: $viewModel.userTitle)
                .font(.pretendard(weight: .semiBold600, size: 24))
                .foregroundStyle(.black)
                .focused($isFocused)
                .padding(EdgeInsets(top: 15, leading: 16, bottom: 15, trailing: 8))
                .background(Color(.pWhite))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(.pPrimary), lineWidth: isFocused ? 1 : 0)
                }
        }
    }
}

private struct PlaylistSongListHeader: View {
    let viewModel: SearchWritingViewModel
    
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
    }
}

private struct PlaylistSongList: View {
    let viewModel: SearchWritingViewModel
    
    var body: some View {
        ForEach(viewModel.diggingList, id: \.songID) { song in
            PlaylistRow(song: song)
        }
        .padding(.horizontal, 8)
    }
}

private struct PlaylistDescriptionTextField: View {
    @Bindable var viewModel: SearchWritingViewModel
    @FocusState private var isFocused: Bool
    
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .foregroundStyle(Color(.pWhite))
            .overlay(alignment: .topLeading) {
                TextField("플레이크에 대한 설명 추가하기", text: $viewModel.userDescription, axis: .vertical)
                    .background(.clear)
                    .foregroundStyle(.black)
                    .padding()
            }
            .frame(height: 65)
    }
}
