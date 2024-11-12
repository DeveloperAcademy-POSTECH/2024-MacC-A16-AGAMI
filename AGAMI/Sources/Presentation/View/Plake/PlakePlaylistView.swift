// swiftlint:disable file_length

//
//  ArchivePlaylistView.swift
//  AGAMI
//
//  Created by 박현수 on 10/15/24.
//

import SwiftUI
import Kingfisher
import PhotosUI

struct PlakePlaylistView: View {
    @State var viewModel: PlakePlaylistViewModel
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.openURL) private var openURL
    @Environment(PlakeCoordinator.self) private var coordinator
    
    init(viewModel: PlakePlaylistViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            ListView(viewModel: viewModel)
            switch viewModel.exportingState {
            case .isAppleMusicExporting:
                AppleMusicLottieView()
            case .isSpotifyExporting:
                SpotifyLottieView()
            case .none:
                EmptyView()
            }
            if viewModel.presentationState.isLoading {
                ProgressView()
            }
        }
        .onAppearAndActiveCheckUserValued(scenePhase)
        .onTapGesture { hideKeyboard() }
        .refreshable { viewModel.refreshPlaylist() }
        .background(Color(.pLightGray))
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
                TopBarTrailingItems(viewModel: viewModel)
                    .foregroundStyle(Color(.pPrimary))
            }
        }
        .navigationTitle(viewModel.presentationState.isEditing ? "편집하기" : "")
        .navigationBarBackButtonHidden()
        .confirmationDialog("", isPresented: $viewModel.presentationState.isExportDialogPresented) {
            ExportConfirmationDialogActions(viewModel: viewModel)
        }
        .confirmationDialog("", isPresented: $viewModel.presentationState.isPhotoDialogPresented) {
            PhotoConfirmationDialogActions(viewModel: viewModel)
        }
        .alert("플레이크 삭제", isPresented: $viewModel.presentationState.isShowingDeletePlakeAlert) {
            DeletePlakeAlertActions(viewModel: viewModel)
        } message: {
            Text("삭제한 플레이크는 되돌릴 수 없습니다.")
        }
        .alert("게정 상태 문제", isPresented: $viewModel.presentationState.isShowingExportingAppleMusicFailedAlert) {
            ExportingFailedAlertActions(viewModel: viewModel)
        } message: {
            Text("플레이크를 내보낼 수 없습니다.\n Apple Music의 계정 상태를 확인해주세요.")
        }
        .alert("기본 이미지로 변경", isPresented: $viewModel.presentationState.isShowingDeletePhotoAlert) {
            DeletePhotoAlertActions(viewModel: viewModel)
        } message: {
            Text("이전 사진은 되돌릴 수 없습니다.")
        }
        .photosPicker(
            isPresented: $viewModel.presentationState.isShowingPicker,
            selection: $viewModel.selectedItem,
            matching: .images
        )
        .onOpenURL { url in
            viewModel.handleURL(url)
        }
        .onChange(of: scenePhase) { _, newScene in
            if newScene == .active && viewModel.presentationState.didOpenSpotifyURL {
                viewModel.resetSpotifyURLState()
            }
        }
    }
}

private struct ListView: View {
    let viewModel: PlakePlaylistViewModel
    
    var body: some View {
        List {
            Group {
                if viewModel.presentationState.isEditing {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("플레이크를 편집해보세요.")
                            .font(.pretendard(weight: .regular400, size: 16))
                            .foregroundStyle(Color(.pGray1))
                            .listRowInsets(EdgeInsets())
                    }
                    .listRowInsets(EdgeInsets(top: 3, leading: 16, bottom: 10, trailing: 16))
                    .listRowSeparator(.hidden)
                }
                
                ImageAndTitleWithHeaderView(viewModel: viewModel)
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                
                ForEach(viewModel.playlist.songs, id: \.songID) { song in
                    ArchivePlaylistRow(viewModel: viewModel, song: song)
                }
                .conditionalModifier(viewModel.presentationState.isEditing) { view in
                    view
                        .onDelete { indexSet in
                            viewModel.deleteMusic(indexSet: indexSet)
                        }
                        .onMove { indices, newOffset in
                            viewModel.moveMusic(from: indices, to: newOffset)
                        }
                }
                .listRowInsets(EdgeInsets(top: 1, leading: 8, bottom: 1, trailing: 8))
                
                Group {
                    if viewModel.presentationState.isEditing {
                        AddSongsButton(viewModel: viewModel)
                    } else {
                        ExportButton(viewModel: viewModel)
                    }
                }
                .listRowInsets(EdgeInsets(top: 12, leading: 8, bottom: 5, trailing: 8))
                .listRowSeparator(.hidden)
                
                PlaylistDescription(viewModel: viewModel)
                    .listRowInsets(EdgeInsets(top: 20, leading: 8, bottom: 0, trailing: 8))
                    .listRowSeparator(.hidden)
            }
            .listRowBackground(Color(.pLightGray))
        }
        .listStyle(.plain)
        .scrollIndicators(.hidden)
    }
}

private struct ArchivePlaylistRow: View {
    let viewModel: PlakePlaylistViewModel
    let song: SongModel
    
    var body: some View {
        HStack(spacing: 0) {
            if !song.albumCoverURL.isEmpty {
                KFImage(URL(string: song.albumCoverURL))
                    .resizable()
                    .cancelOnDisappear(true)
                    .placeholder {
                        ProgressView()
                    }
                    .frame(width: 60, height: 60)
                    .padding(.trailing, 12)
            } else {
                Image(.musicEmpty)
                    .padding(.trailing, 12)
            }
            
            VStack(alignment: .leading, spacing: 0) {
                Text(song.title)
                    .font(.pretendard(weight: .semiBold600, size: 18))
                    .foregroundStyle(Color(.pBlack))
                    .kerning(-0.43)
                    .lineLimit(1)
                
                Text(song.artist)
                    .font(.pretendard(weight: .regular400, size: 14))
                    .foregroundStyle(Color(.pGray1))
                    .kerning(-0.23)
                    .lineLimit(1)
            }
            
            Spacer()
            
            if viewModel.presentationState.isEditing {
                Image(systemName: "line.3.horizontal")
                    .foregroundStyle(.gray)
                    .font(.system(size: 16, weight: .regular))
                Spacer().frame(width: 16)
            }
        }
        .background(Color(.pWhite))
    }
}

private struct ImageAndTitleWithHeaderView: View {
    @Bindable var viewModel: PlakePlaylistViewModel
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .bottom) {
                KFImage(URL(string: viewModel.playlist.photoURL))
                    .resizable()
                    .cancelOnDisappear(true)
                    .placeholder {
                        Image(.coverImageThumbnail)
                            .resizable()
                    }
                    .aspectRatio(1, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.25), radius: 10)
                
                if viewModel.presentationState.isEditing {
                    if viewModel.playlist.photoURL.isEmpty {
                        AddPhotoButton(viewModel: viewModel)
                    } else {
                        DeletePhotoButton(viewModel: viewModel)
                    }
                }
                
                VStack(spacing: 0) {
                    Group {
                        Text(viewModel.playlist.streetAddress)
                            .padding(.bottom, 2)
                        Text(viewModel.formatDateToString(viewModel.playlist.generationTime))
                            .padding(.bottom, viewModel.presentationState.isEditing ? 10 : 16)
                    }
                    .font(.pretendard(weight: .medium500, size: viewModel.presentationState.isEditing ? 15 : 20))
                    .foregroundStyle(Color(.pWhite))
                }
            }
            .padding(.horizontal, viewModel.presentationState.isEditing ? 50 : 0)
            .padding(EdgeInsets(top: 20, leading: 8, bottom: 0, trailing: 8))
            
            if viewModel.presentationState.isEditing {
                Text("플레이크 타이틀")
                    .font(.pretendard(weight: .semiBold600, size: 20))
                    .foregroundStyle(Color(.pBlack))
                    .padding(EdgeInsets(top: 30, leading: 16, bottom: 11, trailing: 16))
                
                TextField("", text: $viewModel.playlist.playlistName)
                    .font(.pretendard(weight: .medium500, size: 20))
                    .foregroundStyle(Color(.pBlack))
                    .tint(Color(.pPrimary))
                    .focused($isFocused)
                    .padding(EdgeInsets(top: 13, leading: 16, bottom: 13, trailing: 16))
                    .background(Color(.pWhite))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(.pPrimary), lineWidth: isFocused ? 1 : 0)
                    }
                    .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
            } else {
                Text(viewModel.playlist.playlistName)
                    .font(.pretendard(weight: .bold700, size: 26))
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(Color(.pBlack))
                    .padding(EdgeInsets(top: 22, leading: 16, bottom: 0, trailing: 16))
            }
            
            HStack(spacing: 0) {
                Text("수집한 노래")
                    .font(.pretendard(weight: .semiBold600, size: 20))
                    .foregroundStyle(Color(.pBlack))
                Spacer()
                Text("\(viewModel.playlist.songs.count)곡")
                    .font(.pretendard(weight: .medium500, size: 16))
                    .foregroundStyle(Color(.pPrimary))
            }
            .padding(EdgeInsets(top: 37, leading: 16, bottom: 10, trailing: 16))
        }
    }
}

private struct DeletePhotoButton: View {
    let viewModel: PlakePlaylistViewModel
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Image(.deletePhotoButton)
                    .padding(EdgeInsets(top: 9, leading: 7, bottom: 9, trailing: 7))
                    .highPriorityGesture(
                        TapGesture().onEnded {
                            viewModel.presentationState.isPhotoDialogPresented = true
                        }
                    )
            }
            Spacer()
        }
    }
}

private struct PlaylistDescription: View {
    @Bindable var viewModel: PlakePlaylistViewModel
    
    var body: some View {
        if viewModel.presentationState.isEditing {
            TextField("플레이크에 대한 설명 추가하기", text: $viewModel.playlist.playlistDescription, axis: .vertical)
                .font(.pretendard(weight: .regular400, size: 16))
                .tint(Color(.pPrimary))
                .foregroundStyle(Color(.pBlack))
                .kerning(-0.3)
                .lineSpacing(3)
                .multilineTextAlignment(.leading)
                .padding(EdgeInsets(top: 16, leading: 8, bottom: 16, trailing: 8))
                .background(Color(.pWhite))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.bottom, 133)
        } else {
            Text(viewModel.playlist.playlistDescription)
                .font(.pretendard(weight: .regular400, size: 16))
                .kerning(-0.3)
                .lineSpacing(3)
                .foregroundStyle(Color(.pBlack))
                .multilineTextAlignment(.leading)
                .padding(.bottom, 133)
        }
    }
}

private struct ExportButton: View {
    let viewModel: PlakePlaylistViewModel
    
    var body: some View {
        HStack(spacing: 6) {
            Spacer()
            Image(.exportPlakeIcon)
            Text("플레이크 내보내기")
                .font(.pretendard(weight: .medium500, size: 20))
                .foregroundStyle(Color(.pPrimary))
                .padding(.vertical, 14)
            Spacer()
        }
        .background(Color(.pGray2))
        .clipShape(RoundedRectangle(cornerRadius: 13))
        .highPriorityGesture(
            TapGesture().onEnded {
                viewModel.presentationState.isExportDialogPresented = true
            }
        )
    }
}

private struct AddSongsButton: View {
    @Environment(PlakeCoordinator.self) private var coordinator
    let viewModel: PlakePlaylistViewModel
    
    var body: some View {
        HStack(spacing: 6) {
            Spacer()
            Image(.addPlakingIcon)
            Text("플레이킹 더하기")
                .font(.pretendard(weight: .medium500, size: 20))
                .foregroundStyle(Color(.pPrimary))
                .padding(.vertical, 14)
            Spacer()
        }
        .background(Color(.pGray2))
        .clipShape(RoundedRectangle(cornerRadius: 13))
        .highPriorityGesture(
            TapGesture().onEnded {
                coordinator.push(route: .addPlakingView(
                    viewModel: AddPlakingViewModel(playlist: viewModel.playlist)
                ))
            }
        )
    }
}

private struct AddPhotoButton: View {
    @Environment(PlakeCoordinator.self) private var coordinator
    let viewModel: PlakePlaylistViewModel
    var body: some View {
        VStack {
            Spacer()
            HStack(spacing: 0) {
                Image(systemName: "camera.viewfinder")
                    .font(.system(size: 17))
                Text(" 사진으로 기록")
                    .font(.pretendard(weight: .medium500, size: 20))
            }
            .foregroundStyle(Color(.pPrimary))
            .highPriorityGesture(
                TapGesture().onEnded {
                    coordinator.push(route: .cameraView(
                        viewModelContainer: .plakePlaylist(viewModel: viewModel)
                    ))
                }
            )
            Spacer()
        }
    }
}

private struct ExportConfirmationDialogActions: View {
    @Environment(\.openURL) private var openURL
    let viewModel: PlakePlaylistViewModel
    
    var body: some View {
        Button {
            Task {
                if let url = await viewModel.exportPlaylistToAppleMusic() {
                    openURL(url)
                }
            }
        } label: {
            Label("Apple Music에서 열기", image: .appleSmallBlackLogo)
        }
        
        Button {
            viewModel.exportPlaylistToSpotify { result in
                switch result {
                case .success(let url):
                    openURL(url)
                case .failure(let err):
                    dump(err.localizedDescription)
                }
            }
        } label: {
            Label("Spotify에서 열기", image: .spotifySmallBlackLogo)
        }
    }
}

private struct PhotoConfirmationDialogActions: View {
    let viewModel: PlakePlaylistViewModel
    
    var body: some View {
        Button("앨범에서 가져오기") {
            viewModel.presentationState.isShowingPicker = true
        }
        Button("기본 이미지로 변경", role: .destructive) {
            viewModel.presentationState.isShowingDeletePhotoAlert = true
        }
    }
}

private struct TopBarTrailingItems: View {
    let viewModel: PlakePlaylistViewModel
    
    var body: some View {
        HStack {
            if viewModel.presentationState.isEditing {
                Button(role: .cancel) {
                    Task {
                        await viewModel.applyChangesToFirestore()
                        viewModel.presentationState.isEditing = false
                    }
                } label: {
                    if viewModel.presentationState.isUpdating {
                        ProgressView()
                    } else {
                        Text("저장")
                            .font(.pretendard(weight: .semiBold600, size: 17))
                            .foregroundStyle(Color(.pPrimary))
                    }
                }
                .disabled(viewModel.presentationState.isUpdating)
            } else if viewModel.exportingState == .none {
                Button {
                    viewModel.presentationState.isEditing = true
                } label: {
                    Text("편집")
                        .font(.pretendard(weight: .regular400, size: 17))
                        .foregroundStyle(Color(.pPrimary))
                }
                Menu {
                    MenuContents(viewModel: viewModel)
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundStyle(Color(.pPrimary))
                }
            }
        }
    }
}

private struct MenuContents: View {
    @Environment(PlakeCoordinator.self) private var coordinator
    let viewModel: PlakePlaylistViewModel
    
    var body: some View {
        Button {
            coordinator.push(route: .addPlakingView(
                viewModel: AddPlakingViewModel(playlist: viewModel.playlist)
            ))
        } label: {
            Label("플레이킹 더하기", image: .menuBlackPlakeLogo)
        }
        
        //        Button {
        //
        //        } label: {
        //            Label("공유하기", systemImage: "square.and.arrow.up")
        //        }
        
        Button {
            Task {
                await viewModel.downloadPhotoAndSaveToAlbum()
            }
        } label: {
            Label("사진 저장", systemImage: "square.and.arrow.down.fill")
        }
        
        Button(role: .destructive) {
            viewModel.presentationState.isShowingDeletePlakeAlert = true
        } label: {
            Label("삭제하기", systemImage: "trash")
        }
    }
}

private struct DeletePhotoAlertActions: View {
    let viewModel: PlakePlaylistViewModel
    
    var body: some View {
        Button("취소", role: .cancel) {
            viewModel.presentationState.isShowingDeletePhotoAlert = false
        }
        
        Button("삭제", role: .destructive) {
            viewModel.deletePhotoURL()
        }
    }
}

private struct DeletePlakeAlertActions: View {
    @Environment(PlakeCoordinator.self) private var coordinator
    let viewModel: PlakePlaylistViewModel
    
    var body: some View {
        Button("취소", role: .cancel) {
            viewModel.presentationState.isShowingDeletePlakeAlert = false
        }
        
        Button("삭제", role: .destructive) {
            Task {
                await viewModel.deletePlaylist()
                coordinator.pop()
            }
        }
    }
}

private struct ExportingFailedAlertActions: View {
    @Environment(PlakeCoordinator.self) private var coordinator
    @Environment(\.openURL) private var openURL
    let viewModel: PlakePlaylistViewModel
    
    var body: some View {
        Button("취소", role: .cancel) {
            viewModel.presentationState.isShowingDeletePlakeAlert = false
        }
        
        Button("확인", role: .destructive) {
            viewModel.presentationState.isShowingDeletePlakeAlert = false
            if let url = URL(string: viewModel.exportAppleMusicURLString) {
                openURL(url)
            }
        }
    }
}
