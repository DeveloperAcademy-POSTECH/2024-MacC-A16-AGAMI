//
//  ArchivePlaylistView.swift
//  AGAMI
//
//  Created by 박현수 on 10/15/24.
//

import SwiftUI
import Kingfisher

struct PlakePlaylistView: View {
    @State var viewModel: PlakePlaylistViewModel
    @Environment(\.openURL) private var openURL

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
        }
        .onTapGesture {
            hideKeyboard()
        }
        .toolbarVisibilityForVersion(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                TopBarTrailingItems(viewModel: viewModel)
            }
        }
        .navigationTitle("플라키브")
        .confirmationDialog("", isPresented: $viewModel.isDialogPresented) {
            ConfirmationDialogActions(viewModel: viewModel)
        }
        .alert("커버 사진 삭제", isPresented: $viewModel.isShowingAlert) {
            AlertActions(viewModel: viewModel)
        } message: {
            Text("삭제한 사진은 되돌릴 수 없습니다.")
        }
        .onOpenURL { url in
            viewModel.handleURL(url)
        }
    }
}

private struct ListView: View {
    let viewModel: PlakePlaylistViewModel

    var body: some View {
        List {
            ImageAndTitleWithHeaderView(viewModel: viewModel)
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)

            ForEach(viewModel.playlist.songs, id: \.songID) { song in
                ArchivePlaylistRow(viewModel: viewModel, song: song)
            }
            .conditionalModifier(viewModel.isEditing) { view in
                view
                    .onDelete { indexSet in
                        viewModel.deleteMusic(indexSet: indexSet)
                    }
                    .onMove { indices, newOffset in
                        viewModel.moveMusic(from: indices, to: newOffset)
                    }
            }
            .listRowInsets(
                EdgeInsets(top: 1, leading: 8, bottom: 1, trailing: 8)
            )

            PlaylistDescription(viewModel: viewModel)
                .listRowInsets(
                    EdgeInsets(top: 25, leading: 8, bottom: 0, trailing: 8)
                )

            ExportButton(viewModel: viewModel)
                .listRowInsets(
                    EdgeInsets(top: 54, leading: 0, bottom: 82, trailing: 0)
                )
                .listRowSeparator(.hidden)
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
            KFImage(URL(string: song.albumCoverURL))
                .resizable()
                .cancelOnDisappear(true)
                .placeholder({
                    ProgressView()
                        .frame(width: 60, height: 60)
                })
                .frame(width: 60, height: 60)
                .padding(.trailing, 12)

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

            if viewModel.isEditing {
                Image(systemName: "line.3.horizontal")
                    .foregroundStyle(.gray)
                    .font(.system(size: 16, weight: .regular))
            }
        }
    }
}

private struct ImageAndTitleWithHeaderView: View {
    @Bindable var viewModel: PlakePlaylistViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .bottom) {
                KFImage(URL(string: viewModel.playlist.photoURL))
                    .resizable()
                    .cancelOnDisappear(true)
                    .placeholder {
                        Image(.photoPlaceHolder)
                            .resizable()
                            .aspectRatio(1, contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: .black.opacity(0.25), radius: 10)
                            .padding(.horizontal, viewModel.isEditing ? 50 : 0)
                    }
                    .aspectRatio(1, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.25), radius: 10)
                    .overlay {
                        if viewModel.isEditing {
                            DeletePhotoButton(viewModel: viewModel)
                        }
                    }
                    .padding(.horizontal, viewModel.isEditing ? 50 : 0)

                VStack(spacing: 0) {
                    Group {
                        Text(viewModel.playlist.streetAddress)
                            .padding(.bottom, viewModel.isEditing ? 9 : 12)
                        Text(viewModel.formatDateToString(viewModel.playlist.generationTime))
                            .padding(.bottom, viewModel.isEditing ? 16 : 22)
                    }
                    .font(.pretendard(weight: .medium500, size: viewModel.isEditing ? 15 : 20))
                    .foregroundStyle(Color(.pWhite))
                }
            }
            .padding(EdgeInsets(top: 20, leading: 8, bottom: 0, trailing: 8))

            if viewModel.isEditing {
                TextField("", text: $viewModel.playlist.playlistName)
                    .font(.pretendard(weight: .semiBold600, size: 28))
                    .foregroundStyle(Color(.pBlack))
                    .padding(16)
                    .background(Color(.pLightGray))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(EdgeInsets(top: 30, leading: 8, bottom: 0, trailing: 8))

            } else {
                Text(viewModel.playlist.playlistName)
                    .font(.pretendard(weight: .bold700, size: 30))
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(Color(.pBlack))
                    .padding(EdgeInsets(top: 22, leading: 16, bottom: 0, trailing: 16))
            }

            HStack(spacing: 0) {
                Text("수집한 플레이크")
                    .font(.pretendard(weight: .semiBold600, size: 23))
                    .foregroundStyle(Color(.pBlack))
                Spacer()
                Text("\(viewModel.playlist.songs.count) 플레이크")
                    .font(.pretendard(weight: .medium500, size: 18))
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
                    .padding(7)
                    .highPriorityGesture(
                        TapGesture().onEnded {
                            viewModel.isShowingAlert = true
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
        if viewModel.isEditing {
            TextField("", text: $viewModel.playlist.playlistDescription, axis: .vertical)
                .font(.pretendard(weight: .regular400, size: 18))
                .foregroundStyle(Color(.pBlack))
                .kerning(-0.3)
                .multilineTextAlignment(.leading)
                .padding(EdgeInsets(top: 16, leading: 8, bottom: 16, trailing: 8))
                .background(Color(.pLightGray))
                .clipShape(RoundedRectangle(cornerRadius: 10))
        } else {
            Text(viewModel.playlist.playlistDescription)
                .font(.pretendard(weight: .regular400, size: 18))
                .kerning(-0.3)
                .foregroundStyle(Color(.pBlack))
                .multilineTextAlignment(.leading)
        }
    }
}

private struct ExportButton: View {
    let viewModel: PlakePlaylistViewModel

    var body: some View {
        HStack {
            Spacer()
            HStack(spacing: 5) {
                Text("플라키브 내보내기")
                    .font(.pretendard(weight: .medium500, size: 20))
                    .foregroundColor(Color(.pWhite))
                    .kerning(-0.41)
                
                Image(systemName: "square.and.arrow.up.on.square.fill")
                    .font(.pretendard(weight: .medium500, size: 18))
                    .foregroundColor(Color(.pWhite))
            }
            .padding(EdgeInsets(top: 13, leading: 50, bottom: 13, trailing: 50))
            .background(Color(.pPrimary))
            .clipShape(Capsule())
            .contentShape(Capsule())
            .highPriorityGesture(
                TapGesture().onEnded {
                    viewModel.isDialogPresented = true
                }
            )
            Spacer()
        }
    }
}

private struct ConfirmationDialogActions: View {
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

private struct TopBarTrailingItems: View {
    let viewModel: PlakePlaylistViewModel

    var body: some View {
        HStack {
            if viewModel.isEditing {
                Button(role: .cancel) {
                    Task {
                        await viewModel.applyChangesToFirestore()
                        viewModel.isEditing = false
                    }
                } label: {
                    if viewModel.isUpdating {
                        ProgressView()
                    } else {
                        Text("완료")
                    }
                }
                .disabled(viewModel.isUpdating)
            } else {
                Button("편집") {
                    viewModel.isEditing = true
                }
                Menu {
                    MenuContents(viewModel: viewModel)
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 17, weight: .regular))
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

        } label: {
            Label("공유하기", systemImage: "square.and.arrow.up")
        }

        Button(role: .destructive) {
            Task {
                await viewModel.deletePlaylist()
                coordinator.pop()
            }
        } label: {
            Label("삭제하기", systemImage: "trash")
        }
    }
}

private struct AlertActions: View {
    let viewModel: PlakePlaylistViewModel

    var body: some View {
        Button("취소", role: .cancel) {
            viewModel.isShowingAlert = false
        }

        Button("삭제", role: .destructive) {
            viewModel.deletePhotoURL()
        }
    }
}
