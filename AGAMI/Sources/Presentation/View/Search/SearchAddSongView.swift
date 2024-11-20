//
//  SearchAddSongView.swift
//  AGAMI
//
//  Created by Seoyeon Choi on 10/16/24.
//

import SwiftUI

import PhotosUI

struct SearchAddSongView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(PlakeCoordinator.self) private var coordinator
    @Environment(ListCellPlaceholderModel.self) private var listCellPlaceholder
    @State var viewModel: SearchAddSongViewModel
    
    init(viewModel: SearchAddSongViewModel) {
        _viewModel = State(initialValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            Color(.pLightGray)
                .ignoresSafeArea()
            
            PlaylistSongList(viewModel: viewModel)
        }
        .onAppearAndActiveCheckUserValued(scenePhase)
        .confirmationDialog("", isPresented: $viewModel.showSheet) {
            Button("카메라") {

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
                      selection: $viewModel.selectedItem,
                      matching: .images)
        .onChange(of: viewModel.selectedItem) {
            Task {
                await viewModel.loadImageFromGallery()
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
        .listStyle(PlainListStyle())
        .tint(Color(.pPrimary))
        .scrollDisabled(viewModel.isSaving)
        .allowsHitTesting(!viewModel.isSaving)
        .navigationTitle("커버 사진")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden()
        .scrollIndicators(.hidden)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    coordinator.pop()
                } label: {
                    Image(systemName: "chevron.backward")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color(.pPrimary))
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task {
                        coordinator.popToRoot()
                        listCellPlaceholder.setListCellPlaceholderModel(
                            userTitle: viewModel.playlist.playlistName,
                            streetAddress: viewModel.playlist.streetAddress,
                            generationTime: Date()
                        )
                        if await viewModel.savedPlaylist() {
                            listCellPlaceholder.resetListCellPlaceholderModel()
                            viewModel.clearDiggingList()
                        } else {
                            dump("Failed to save playlist. Please try again.")
                        }
                    }
                } label: {
                    Text("저장")
                        .font(.pretendard(weight: .semiBold600, size: 17))
                        .foregroundStyle(Color(.pPrimary))
                }
                .disabled(viewModel.isSaving)
            }
        }
    }
}

private struct PlaylistCoverImageView: View {
    let viewModel: SearchAddSongViewModel
    
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
                                Text(viewModel.cellAddress)
                                    .font(.pretendard(weight: .medium500, size: 14))
                                    .foregroundStyle(Color(.pWhite))
                                
                                Text(viewModel.cellDate)
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

private struct PlaylistSongListHeader: View {
    let viewModel: SearchAddSongViewModel
    
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
    let viewModel: SearchAddSongViewModel
    
    var body: some View {
        ForEach(viewModel.diggingList, id: \.songID) { song in
            PlaylistRow(song: song)
        }
        .padding(.horizontal, 8)
    }
}
