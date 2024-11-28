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
            if viewModel.presentationState.isShowingSongDetailView {
                SongDetailView(detailSong: viewModel.detailSong,
                               isLoading: viewModel.presentationState.isDetailViewLoading,
                               dismiss: { viewModel.dismissSongDetailView() })
                .task { await viewModel.fetchAdditionalDetails() }
            }
        }
        .background(viewModel.presentationState.isEditing ? Color(.sTitleText) : Color(.sMain))
        .onAppear(perform: viewModel.refreshPlaylist)
        .onAppearAndActiveCheckUserValued(scenePhase)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                TopBarLeadingItems(viewModel: viewModel)
            }
            ToolbarItem(placement: .topBarTrailing) {
                TopBarTrailingItems(viewModel: viewModel)
            }
        }
        .toolbarBackground(viewModel.presentationState.isEditing ? Color(.sTitleText) : Color(.sMain), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .navigationBarBackButtonHidden()
        .onTapGesture(perform: hideKeyboard)
        .refreshable { viewModel.refreshPlaylist() }
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
        .onOpenURL { viewModel.handleURL($0) }
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
        VStack(spacing: 0) {
            List {
                Group {
                    if !viewModel.playlist.photoURL.isEmpty {
                        ImageView(viewModel: viewModel)
                            .listRowBackground(viewModel.presentationState.isEditing ? Color(.sTitleText) : Color(.sMain))
                            .listRowSeparator(.hidden)
                    }
                    
                    TitleAndDescriptionView(viewModel: viewModel)
                        .listRowBackground(viewModel.presentationState.isEditing ? Color(.sWhite) : Color(.sMain))
                        .listRowSeparator(.hidden)
                    
                    PlaylistView(viewModel: viewModel)
                        .listRowBackground(viewModel.presentationState.isEditing ? Color(.sTitleText) : Color(.sMain))
                    
                    Spacer().frame(height: 60)
                        .listRowBackground(viewModel.presentationState.isEditing ? Color(.sTitleText) : Color(.sMain))
                        .listRowSeparator(.hidden, edges: .bottom)
                    
                }
                .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
            }
            .listStyle(.plain)
            .scrollIndicators(.hidden)
            
            if viewModel.presentationState.isEditing {
                BottomConfigurationBar(viewModel: viewModel)
            }
        }
    }
}

private struct ListRow: View {
    let viewModel: PlakePlaylistViewModel
    let song: SongModel
    
    var body: some View {
        HStack(spacing: 0) {
            if !song.albumCoverURL.isEmpty {
                KFImage(URL(string: song.albumCoverURL))
                    .resizable()
                    .cancelOnDisappear(true)
                    .placeholder { ProgressView() }
                    .frame(width: 60, height: 60)
                    .padding(.trailing, 12)
            } else {
                Image(.songEmpty)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .padding(.trailing, 12)
            }
            
            VStack(alignment: .leading) {
                Text(song.title)
                    .font(.notoSansKR(weight: .semiBold600, size: 16))
                    .kerning(-0.3)
                    .foregroundStyle(viewModel.presentationState.isEditing ? Color(.sMain) : Color(.sTitleText))
                    .lineLimit(1)
                
                Text(song.artist)
                    .font(.notoSansKR(weight: .regular400, size: 14))
                    .foregroundStyle(Color(.sBodyText))
                    .kerning(-0.3)
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
        .background(viewModel.presentationState.isEditing ? Color(.sTitleText) : Color(.sMain))
    }
}

private struct ImageView: View {
    @Environment(PlakeCoordinator.self) private var coordinator
    @Bindable var viewModel: PlakePlaylistViewModel

    var body: some View {
        ZStack {
            if !viewModel.playlist.photoURL.isEmpty {
                KFImage(URL(string: viewModel.playlist.photoURL))
                    .resizable()
                    .cancelOnDisappear(true)
                    .placeholder {
                        Image(.sologPlaceholder)
                            .resizable()
                    }
                    .scaledToFill()
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .highPriorityGesture(
                        TapGesture().onEnded {
                            coordinator.push(route: .imageViewerView(urlString: viewModel.playlist.photoURL))
                        }
                    )
                
                if viewModel.showDeleteButton {
                    DeletePhotoButton(viewModel: viewModel)
                }
            }
        }
        .padding(.top, 4)
        .padding(.bottom, viewModel.presentationState.isEditing ? 12 : 0)
    }
}

private struct TitleAndDescriptionView: View {
    @Bindable var viewModel: PlakePlaylistViewModel
    
    var body: some View {
        switch viewModel.presentationState.isEditing {
        case true:
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .bottom, spacing: 6) {
                    TextField(viewModel.playlist.playlistName, text: $viewModel.playlist.playlistName)
                        .font(.sCoreDream(weight: .dream5, size: 24))
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(Color(.sTitleText))
                        .onChange(of: viewModel.playlist.playlistName) { _, newValue in
                            if newValue.count > 15 {
                                viewModel.playlist.playlistName = String(newValue.prefix(15))
                            }
                        }
                        .padding(EdgeInsets(top: 22, leading: 0, bottom: 0, trailing: 0))
                    Spacer()
                    Text("\(viewModel.playlist.playlistName.count)/15")
                        .font(.notoSansKR(weight: .regular400, size: 13))
                        .foregroundStyle(Color(.sTextCaption))
                }
                
                Divider().frame(height: 0.5)
                    .background(Color(.sLine))
                    .padding(.vertical, 12)
                
                TextField("기록하고 싶은 내용을 작성해보세요", text: $viewModel.playlist.playlistDescription, axis: .vertical)
                    .font(.notoSansKR(weight: .regular400, size: 15))
                    .foregroundStyle(Color(.sBodyText))
                    .lineSpacing(3)
                    .padding(.top, 12)
                    .padding(.bottom, 32)
            }
        case false:
            VStack(alignment: .leading, spacing: 0) {
                Text(viewModel.playlist.playlistName)
                    .font(.sCoreDream(weight: .dream5, size: 24))
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(Color(.sTitleText))
                    .padding(EdgeInsets(top: 22, leading: 0, bottom: 0, trailing: 0))
                
                Divider().frame(height: 0.5)
                    .background(Color(.sLine))
                    .padding(.vertical, 12)

                HStack(spacing: 11) {
                    Text(viewModel.formatDateToString(viewModel.playlist.generationTime))
                        .font(.notoSansKR(weight: .regular400, size: 15))
                        .foregroundStyle(Color(.sSubHead))
                        .lineLimit(1)
                    
                    Divider().frame(width: 0.5).background(Color(.sLine))
                    
                    Text(viewModel.playlist.streetAddress)
                        .font(.notoSansKR(weight: .regular400, size: 15))
                        .foregroundStyle(Color(.sSubHead))
                        .lineLimit(1)
                    Spacer()
                }
                .fixedSize(horizontal: false, vertical: true)
                
                Divider().frame(height: 0.5)
                    .background(Color(.sLine))
                    .padding(.vertical, 12)

                if !viewModel.playlist.playlistDescription.isEmpty {
                    Text(viewModel.playlist.playlistDescription.forceCharWrapping)
                        .font(.notoSansKR(weight: .regular400, size: 15))
                        .foregroundStyle(Color(.sBodyText))
                        .lineSpacing(3)
                        .lineLimit(nil)

                    Divider().frame(height: 0.5)
                        .background(Color(.sLine))
                        .padding(.top, 12)
                }
            }
        }
    }
}

private struct PlaylistView: View {
    let viewModel: PlakePlaylistViewModel
    
    var body: some View {
        HStack(spacing: 8) {
            Text("수집한 음악")
                .font(.notoSansKR(weight: .medium500, size: 17))
                .foregroundStyle(viewModel.presentationState.isEditing ? Color(.sMain) : Color(.sTitleText))
            Text("\(viewModel.playlist.songs.count)곡")
                .font(.notoSansKR(weight: .medium500, size: 17))
                .foregroundStyle(Color(.sBodyText))
        }
        .padding(.vertical, 14)
        .listRowSeparator(.hidden)
        
        ForEach(viewModel.playlist.songs, id: \.songID) { song in
            ListRow(viewModel: viewModel, song: song)
                .highPriorityGesture(
                    TapGesture().onEnded {
                        viewModel.presentationState.isShowingSongDetailView.toggle()
                        viewModel.selectedSong = song
                    }
                )
        }
        .conditionalModifier(viewModel.presentationState.isEditing) { view in
            view
                .onDelete(perform: viewModel.deleteSong)
                .onMove(perform: viewModel.moveSong)
        }
        .listRowInsets(EdgeInsets(top: 2, leading: 20, bottom: 2, trailing: 20))
    }
}

private struct DeletePhotoButton: View {
    let viewModel: PlakePlaylistViewModel
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Image(systemName: "xmark.circle")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .fontWeight(.light)
                    .foregroundStyle(Color(.sMain))
                    .padding(EdgeInsets(top: 8, leading: 16, bottom: 16, trailing: 8))
                    .highPriorityGesture(
                        TapGesture().onEnded {
                            viewModel.presentationState.isShowingDeletePhotoAlert = true
                        }
                    )
            }
            Spacer()
        }
    }
}

private struct BottomConfigurationBar: View {
    @Environment(PlakeCoordinator.self) private var coordinator
    let viewModel: PlakePlaylistViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                AddPhotoButton(viewModel: viewModel)
                    .highPriorityGesture(
                        TapGesture().onEnded {
                            viewModel.presentationState.isPhotoDialogPresented = true
                        }
                    )
                Divider().frame(width: 0.5).foregroundStyle(Color(.sLine))
                AddMusicButton(viewModel: viewModel)
                    .highPriorityGesture(
                        TapGesture().onEnded {
                            coordinator.presentSheet(.plakeAddSongView(viewModel: viewModel))
                        }
                    )
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(.top, 20)
            
            Spacer()
        }
        .background(Color(.sWhite))
        .frame(height: 64)
    }
}

private struct AddPhotoButton: View {
    let viewModel: PlakePlaylistViewModel
    
    var body: some View {
        Spacer()
        Image(systemName: "photo")
            .font(.system(size: 17))
            .foregroundStyle(Color(.sButton))
        Text(" 사진 추가")
            .font(.notoSansKR(weight: .semiBold600, size: 15))
            .foregroundStyle(Color(.sButton))
        Spacer()
    }
}

private struct AddMusicButton: View {
    let viewModel: PlakePlaylistViewModel
    
    var body: some View {
        Spacer()
        Image(systemName: "music.note")
            .font(.system(size: 17))
            .foregroundStyle(Color(.sButton))
        Text(" 음악 추가")
            .font(.notoSansKR(weight: .semiBold600, size: 15))
            .foregroundStyle(Color(.sButton))
        Spacer()
    }
}

private struct PhotoConfirmationDialogActions: View {
    @Environment(PlakeCoordinator.self) private var coordinator
    let viewModel: PlakePlaylistViewModel
    
    var body: some View {
        Button("카메라") {
            coordinator.push(route: .cameraView(
                viewModelContainer: .plakePlaylist(viewModel: viewModel)
            ))
        }
        Button("앨범에서 가져오기") {
            viewModel.presentationState.isShowingPicker = true
        }
    }
}

private struct TopBarLeadingItems: View {
    @Environment(PlakeCoordinator.self) private var coordinator
    let viewModel: PlakePlaylistViewModel
    
    var body: some View {
        Button {
            viewModel.simpleHaptic()
            coordinator.pop()
        } label: {
            Image(systemName: "chevron.backward")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(viewModel.presentationState.isEditing ? Color(.sMain) : Color(.sButton))
        }
    }
}

private struct TopBarTrailingItems: View {
    @Environment(PlakeCoordinator.self) private var coordinator
    let viewModel: PlakePlaylistViewModel
    
    var body: some View {
        HStack {
            if viewModel.presentationState.isEditing {
                Button {
                    viewModel.simpleHaptic()
                    viewModel.resetPlaylist()
                    viewModel.presentationState.isEditing = false
                } label: {
                    Text("취소")
                        .font(.notoSansKR(weight: .regular400, size: 16))
                        .foregroundStyle(Color(.sMain))
                }
                
                Button(role: .cancel) {
                    viewModel.simpleHaptic()
                    Task {
                        await viewModel.applyChangesToFirestore()
                        viewModel.presentationState.isEditing = false
                    }
                } label: {
                    if viewModel.presentationState.isUpdating {
                        ProgressView()
                            .tint(Color(.sMain))
                    } else {
                        Text("저장")
                            .font(.notoSansKR(weight: .semiBold600, size: 16))
                            .foregroundStyle(Color(.sMain))
                    }
                }
                .disabled(viewModel.presentationState.isUpdating)
            } else if viewModel.exportingState == .none {
                Button {
                    viewModel.simpleHaptic()
                    viewModel.presentationState.isEditing = true
                } label: {
                    Image(systemName: "pencil.circle")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(Color(.sButton))
                }
                Button {
                    viewModel.simpleHaptic()
                    coordinator.presentSheet(.playlistMapView(playlist: viewModel.playlist))
                } label: {
                    Image(systemName: "location.circle")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(Color(.sButton))
                }
                Menu {
                    MenuContents(viewModel: viewModel)
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(Color(.sButton))
                }
            }
        }
        .foregroundStyle(Color(.sTitleText))
    }
}

private struct MenuContents: View {
    @Environment(\.openURL) private var openURL
    let viewModel: PlakePlaylistViewModel
    
    var body: some View {
        Button {
            viewModel.simpleHaptic()
            Task {
                if let url = await viewModel.exportPlaylistToAppleMusic() {
                    openURL(url)
                }
            }
        } label: {
            Label("Apple Music로 듣기", systemImage: "music.note.list")
        }
        
        Button {
            viewModel.simpleHaptic()
            viewModel.exportPlaylistToSpotify { result in
                switch result {
                case .success(let url):
                    openURL(url)
                case .failure(let err):
                    dump(err)
                }
            }
        } label: {
            Label("Spotify로 듣기", systemImage: "music.note.list")
        }
        
        Button {
            viewModel.simpleHaptic()
            Task {
                if let url = await viewModel.getInstagramStoryURL() {
                    openURL(url)
                }
            }
        } label: {
            Label("스토리로 공유하기", systemImage: "square.and.arrow.up")
        }
        
        Button(role: .destructive) {
            viewModel.simpleHaptic()
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
