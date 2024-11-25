//
//  SearchWritingView.swift
//  AGAMI
//
//  Created by Seoyeon Choi on 10/15/24.
//

import SwiftUI

struct SearchWritingView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(PlakeCoordinator.self) private var coordinator
    @State private var viewModel: SearchWritingViewModel = SearchWritingViewModel()
    
    var body: some View {
        ZStack(alignment: .top) {
            Color(.sMain)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                List {
                    Group {
                        if viewModel.playlist.photoData != nil {
                            SearchCoverImageView(viewModel: viewModel)
                                .padding(.top, 3)
                        }
                        SearchTitleTextField(viewModel: viewModel)
                            .padding(.top, 19)
                        SearchDescriptionTextField(viewModel: viewModel)
                            .padding(.top, 24)
                        SearchSongListHeader(viewModel: viewModel)
                            .padding(.top, 24)
                    }
                    .listRowInsets(.zero)
                    .listRowBackground(Color(.sMain))
                    .listRowSeparator(.hidden)
                    
                    SearchSongList(viewModel: viewModel)
                        .listRowInsets(.zero)
                        .listRowBackground(Color(.sMain))
                }
                .listStyle(.plain)
                .scrollIndicators(.hidden)
                SearchAddButton(viewModel: viewModel)
            }
            
        }
        .task { await viewModel.fetchCurrentLocation() }
        .ignoresSafeArea(edges: .bottom)
        .onAppearAndActiveCheckUserValued(scenePhase)
        .onTapGesture(perform: hideKeyboard)
        .scrollDisabled(viewModel.isPhotoLoading)
        .navigationBarBackButtonHidden(true)
        .photosPicker(isPresented: $viewModel.showPhotoPicker,
                      selection: $viewModel.selectedItem,
                      matching: .images)
        .onChange(of: viewModel.selectedItem) {
            Task {
                await viewModel.loadImageFromGallery()
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                TopBarLeadingItems(viewModel: viewModel)
            }
            ToolbarItem(placement: .topBarTrailing) {
                TopbarTrailingItems(viewModel: viewModel)
            }
        }
        .confirmationDialog("", isPresented: $viewModel.showPhotoConfirmDialog) {
            PhotoConfirmationDialogActions(viewModel: viewModel)
        }
        .alert("기록 그만두기", isPresented: $viewModel.showBackButtonAlert) {
            BackButtonAlertActions(viewModel: viewModel)
        } message: {
            Text("만들던 기록은 사라집니다.")
        }
        .alert(isPresented: $viewModel.showDeleteImageAlert) {
            Alert(
                title: Text("사진 삭제하기")
                    .font(.notoSansKR(weight: .semiBold600, size: 17))
                    .foregroundStyle(Color(.sTitleText)),
                message: Text("기록한 사진을 삭제할까요?")
                    .font(.notoSansKR(weight: .regular400, size: 14))
                    .foregroundStyle(Color(.sBodyText)),
                primaryButton: .default(Text("취소")) {
                    viewModel.showDeleteImageAlert = false
                },
                secondaryButton: .destructive(Text("삭제")) {
                    viewModel.resetImage()
                }
            )
        }
    }
}

private struct SearchCoverImageView: View {
    let viewModel: SearchWritingViewModel
    
    var body: some View {
        ZStack {
            if let photoData = viewModel.playlist.photoData,
               let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 257)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .overlay(alignment: .topTrailing) {
                        Image(systemName: "x.circle")
                            .font(.system(size: 20, weight: .light))
                            .foregroundStyle(Color(.sMain))
                            .padding(8)
                            .highPriorityGesture(
                                TapGesture().onEnded {
                                    viewModel.showDeleteImageAlert = true
                                }
                            )
                    }
                    .padding(.horizontal, 16)
            }
            
            if viewModel.isPhotoLoading {
                ProgressView("사진 로딩 중...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .frame(height: 257)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .padding(.horizontal, 16)
            }
        }
    }
}

private struct SearchTitleTextField: View {
    @Bindable var viewModel: SearchWritingViewModel
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("오늘의 기록")
                .font(.notoSansKR(weight: .regular400, size: 15))
                .foregroundStyle(Color(.sSubHead))
                .padding(.bottom, 6)
            
            HStack(spacing: 0) {
                TextField("타이틀 입력", text: $viewModel.playlist.playlistName)
                    .font(.sCoreDream(weight: .dream5, size: 24))
                    .foregroundStyle(Color(.sTitleText))
                    .tint(Color(.sTitleText))
                    .focused($isFocused)
                    .background(Color(.sMain))
                    .onChange(of: viewModel.playlist.playlistName) { _, newValue in
                        if newValue.count > viewModel.maximumTitleLength {
                            viewModel.playlist.playlistName = String(newValue.prefix(viewModel.maximumTitleLength))
                        }
                    }
                
                Text("\(viewModel.playlist.playlistName.count)/\(viewModel.maximumTitleLength)")
                    .font(.notoSansKR(weight: .regular400, size: 13))
                    .foregroundStyle(Color(.sTextCaption))
            }
            .padding(.bottom, 6)
            
            Divider()
                .frame(height: 0.5)
                .foregroundStyle(Color(.sLine))
        }
        .padding(.horizontal, 20)
    }
}

private struct SearchDescriptionTextField: View {
    @Bindable var viewModel: SearchWritingViewModel
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            TextField("기록하고 싶었던 순간이나 생각과 감정을 작성해보세요.",
                      text: $viewModel.playlist.playlistDescription,
                      axis: .vertical)
            .font(.notoSansKR(weight: .regular400, size: 15))
            .background(Color(.sMain))
        }
        .padding(.horizontal, 20)
    }
}

private struct SearchAddButton: View {
    @Environment(PlakeCoordinator.self) private var coordinator
    let viewModel: SearchWritingViewModel
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            Spacer()
            
            Label {
                Text("사진 추가")
                    .font(.notoSansKR(weight: .semiBold600, size: 15))
            } icon: {
                Image(systemName: "photo")
                    .font(.system(size: 17, weight: .regular))
            }
            .onTapGesture {
                viewModel.showPhotoConfirmDialog.toggle()
                viewModel.simpleHaptic()
            }
            
            Spacer()
            
            Divider()
                .frame(width: 0.5, height: 20)
                .foregroundStyle(Color(.sLine))
            
            Spacer()
            
            Label {
                Text("음악 추가")
                    .font(.notoSansKR(weight: .semiBold600, size: 15))
            } icon: {
                Image(systemName: "music.note")
                    .font(.system(size: 17, weight: .regular))
            }
            .onTapGesture {
                let searchAddSongViewModel = viewModel.createSearchAddSongViewModel()
                coordinator.presentSheet(.searchAddSongView(viewModel: searchAddSongViewModel))
                viewModel.simpleHaptic()
            }
            
            Spacer()
        }
        .padding(.top, 20)
        .padding(.bottom, 51)
        .foregroundStyle(Color(.sButton))
        .background(Color(.sWhite))
    }
}

private struct SearchSongListHeader: View {
    var viewModel: SearchWritingViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            if !viewModel.diggingList.isEmpty {
                Divider()
                    .frame(height: 0.5)
                    .foregroundStyle(Color(.sLine))
                    .padding(.horizontal, 20)
                HStack(spacing: 0) {
                    Text("수집한 노래")
                        .font(.notoSansKR(weight: .medium500, size: 17))
                        .foregroundStyle(Color(.sTitleText))
                        .padding(.trailing, 8)
                    
                    Text("\(viewModel.diggingList.count)곡")
                        .font(.notoSansKR(weight: .medium500, size: 17))
                        .foregroundStyle(Color(.sSubHead))
                    
                    Spacer()
                }
                .padding(.leading, 20)
                .padding(.vertical, 14)
            }
        }
    }
}

private struct SearchSongList: View {
    let viewModel: SearchWritingViewModel
    
    var body: some View {
        ForEach(viewModel.diggingList, id: \.songID) { song in
            PlaylistRow(song: song, isHighlighted: true)
        }
        .padding(.horizontal, 20)
    }
}

private struct TopBarLeadingItems: View {
    @Environment(PlakeCoordinator.self) private var coordinator
    var viewModel: SearchWritingViewModel
    
    var body: some View {
        Button {
            viewModel.simpleHaptic()
            if viewModel.diggingList.isEmpty {
                viewModel.clearDiggingList()
                coordinator.pop()
            } else {
                viewModel.showBackButtonAlert = true
            }
        } label: {
            Image(systemName: "chevron.backward")
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(Color(.sButton))
        }
    }
}

private struct TopbarTrailingItems: View {
    @Environment(ListCellPlaceholderModel.self) private var placeholderData
    @Environment(PlakeCoordinator.self) private var coordinator
    var viewModel: SearchWritingViewModel
    
    var body: some View {
        Button {
            Task {
                viewModel.simpleHaptic()
                placeholderData.setListCellPlaceholderModel(
                    userTitle: viewModel.playlist.playlistName,
                    streetAddress: viewModel.playlist.streetAddress,
                    generationTime: Date()
                )
                coordinator.popToRoot()

                if await viewModel.savedPlaylist() {
                    placeholderData.resetListCellPlaceholderModel()
                    viewModel.clearDiggingList()
                } else {
                    dump("Failed to save playlist. Please try again.")
                }
            }
        } label: {
            Text("저장")
                .font(.pretendard(weight: .medium500, size: 17))
                .foregroundStyle(viewModel.saveButtonEnabled ? Color(.sButton) : Color(.sButtonDisabled))
        }
        .disabled(!viewModel.saveButtonEnabled)
    }
}

private struct BackButtonAlertActions: View {
    @Environment(PlakeCoordinator.self) private var coordinator
    let viewModel: SearchWritingViewModel

    var body: some View {
        Button("취소", role: .cancel) { }
        Button("확인", role: .destructive) {
            viewModel.clearDiggingList()
            coordinator.pop()
        }
    }
}

private struct PhotoConfirmationDialogActions: View {
    @Environment(PlakeCoordinator.self) private var coordinator
    let viewModel: SearchWritingViewModel
    
    var body: some View {
        Button("사진 찍기") {
            coordinator.push(route: .cameraView(viewModelContainer: .searchWriting(viewModel: viewModel)))
        }
        Button("사진 보관함 열기") {
            viewModel.showPhotoPicker = true
        }
    }
}

#Preview {
    SearchWritingView()
}
