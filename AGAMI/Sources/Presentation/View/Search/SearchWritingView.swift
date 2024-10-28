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
    @FocusState var isFocused: Bool
    @State private var showActionSheet: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                AsyncImage(url: URL(string: viewModel.photoUrl)) { image in
                    image
                        .resizable()
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .aspectRatio(1, contentMode: .fit)
                        .padding(.horizontal, 58)
                        .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 4)
                } placeholder: {
                    Image(.basicCover)
                        .padding(.horizontal, 58)
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
                .onTapGesture {
                    if viewModel.photoUrl == "" {
                        coordinator.push(view: .cameraView(viewModel: viewModel))
                    } else {
                        showActionSheet.toggle()
                    }
                }
                
                //TODO: 실시간 위치 넣기
                TextField("효자동에서 만난 플레이크", text: $viewModel.userTitle)
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
                    .padding(.top, 30)
                    .padding(.horizontal, 8)
                
                HStack(spacing: 0) {
                    Text("수집한 플레이크")
                        .font(.pretendard(weight: .semiBold600, size: 20))
                        .foregroundStyle(Color(.pBlack))
                    Spacer()
                    Text("\(viewModel.diggingList.count) 플레이크")
                        .font(.pretendard(weight: .medium500, size: 16))
                        .foregroundStyle(Color(.pPrimary))
                }
                .padding(.top, 40)
                .padding(.horizontal, 24)
                
                List {
                    ForEach(viewModel.diggingList, id: \.songID) { song in
                        PlaylistRow(song: song)
                    }
                }
                .listStyle(PlainListStyle())
                .padding(.horizontal, 8)
                
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(Color(.pLightGray))
                    .overlay(alignment: .topLeading) {
                        TextField("플레이크에 대한 설명 추가하기", text: $viewModel.userDescription, axis: .vertical)
                            .background(.clear)
                            .foregroundStyle(.black)
                            .padding()
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
                            viewModel.hideProgress()
                            coordinator.popToRoot()
                        }
                    } label: {
                        Text("저장")
                    }
                    .frame(height: 65)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 13)
                }
                .disabled(!viewModel.isLoaded)
            }
            .confirmationDialog("", isPresented: $showActionSheet) {
                Button("다시 찍기") {
                    coordinator.push(view: .cameraView(viewModel: viewModel))
                }
                Button("기본 이미지로 변경") {
                    viewModel.photoUrl = ""
                }
                Button("취소", role: .cancel) {}
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
                            .font(.pretendard(weight: .semiBold600, size: 17))
                    }
                }
            .disabled(viewModel.isLoading)
            .blur(radius: viewModel.isLoading ? 10 : 0)
            
            if viewModel.isLoading {
                ProgressView()
                
            }
            .toolbarRole(.editor)
        }
        .onTapGesture {
            hideKeyboard()
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
