//
//  ArchivePlaylistView.swift
//  AGAMI
//
//  Created by 박현수 on 10/15/24.
//

import SwiftUI
import Kingfisher
import Lottie

struct ArchivePlaylistView: View {
    @State var viewModel: ArchivePlaylistViewModel
    @Environment(\.openURL) private var openURL

    var body: some View {
        ZStack {
            ListView(viewModel: viewModel)
            switch viewModel.exportingState {
            case .isAppleMusicExporting:
                CustomLottieView(.applemusicExporting)
            case .isSpotifyExporting:
                CustomLottieView(.spotifyExporting)
            case .none:
                EmptyView()
            }
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
            Button("취소", role: .cancel) {
                viewModel.isShowingAlert = false
            }
            Button("삭제", role: .destructive) {
                viewModel.deletePhotoURL()
            }
        } message: {
            Text("삭제한 사진은 되돌릴 수 없습니다.")
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
}

private struct ListView: View {
    var viewModel: ArchivePlaylistViewModel

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
                EdgeInsets(top: 1, leading: 16, bottom: 1, trailing: 16)
            )

            PlaylistDescription(viewModel: viewModel)
                .listRowInsets(
                    EdgeInsets(top: 25, leading: 16, bottom: 0, trailing: 16)
                )

            ExportButton(viewModel: viewModel)
                .listRowInsets(
                    EdgeInsets(top: 54, leading: 0, bottom: 82, trailing: 0)
                )
                .listRowSeparator(.hidden)

        }
        .listStyle(.plain)
    }
}

private struct ArchivePlaylistRow: View {
    let viewModel: ArchivePlaylistViewModel
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
                .padding(.trailing, 20)

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
    @Bindable var viewModel: ArchivePlaylistViewModel
    @State private var asyncImageOpacity: Double = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .bottom) {
                AsyncImage(
                    url: URL(string: viewModel.playlist.photoURL)
                ) { image in
                    image
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .black.opacity(0.25), radius: 10)
                        .opacity(asyncImageOpacity)
                        .onAppear {
                            withAnimation(.easeOut(duration: 1)) {
                                asyncImageOpacity = 1
                            }
                        }
                } placeholder: {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.white)
                        .aspectRatio(1, contentMode: .fit)
                }

                VStack(spacing: 0) {
                    Group {
                        Text(viewModel.playlist.streetAddress)
                            .padding(.bottom, 12)
                        Text(
                            viewModel
                                .formatDateToString(
                                    viewModel.playlist.generationTime
                                )
                        )
                        .padding(.bottom, 22)
                    }
                    .font(.pretendard(weight: .medium500, size: 20))
                    .foregroundStyle(Color(.pWhite))
                }

                if viewModel.showDeleteButton {
                    VStack {
                        HStack {
                            Spacer()
                            Image(.deletePhotoButton)
                                .padding(7)
                                .onTapGesture {
                                    viewModel.isShowingAlert = true
                                }
                        }
                        Spacer()
                    }
                }
            }
            .padding(EdgeInsets(top: 20, leading: 8, bottom: 0, trailing: 8))

            if viewModel.isEditing {
                TextField("", text: $viewModel.playlist.playlistName)
                    .font(.pretendard(weight: .bold700, size: 26))
                    .foregroundStyle(Color(.pBlack))
                    .padding(16)
                    .background(Color(.pLightGray))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(EdgeInsets(top: 30, leading: 16, bottom: 0, trailing: 16))

            } else {
                Text(viewModel.playlist.playlistName)
                    .font(.pretendard(weight: .bold700, size: 26))
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(Color(.pBlack))
                    .padding(EdgeInsets(top: 30, leading: 16, bottom: 0, trailing: 16))
            }

            HStack(alignment: .bottom, spacing: 0) {
                Text("수집한 플레이크")
                    .font(.pretendard(weight: .semiBold600, size: 20))
                    .foregroundStyle(Color(.pBlack))
                Spacer()
                Text("\(viewModel.playlist.songs.count) 플레이크")
                    .font(.pretendard(weight: .medium500, size: 16))
                    .foregroundStyle(Color(.pPrimary))
            }
            .padding(EdgeInsets(top: 49, leading: 16, bottom: 16, trailing: 16))
        }
    }
}

private struct PlaylistDescription: View {
    @Bindable var viewModel: ArchivePlaylistViewModel

    var body: some View {
        if viewModel.isEditing {
            TextField("", text: $viewModel.playlist.playlistDescription)
                .font(.pretendard(weight: .regular400, size: 16))
                .foregroundStyle(Color(.pBlack))
                .multilineTextAlignment(.leading)
                .padding(EdgeInsets(top: 16, leading: 8, bottom: 16, trailing: 8))
                .background(Color(.pLightGray))
                .clipShape(RoundedRectangle(cornerRadius: 10))
        } else {
            Text(viewModel.playlist.playlistDescription)
                .font(.pretendard(weight: .regular400, size: 16))
                .foregroundStyle(Color(.pBlack))
                .multilineTextAlignment(.leading)
        }
    }
}

private struct ExportButton: View {
    var viewModel: ArchivePlaylistViewModel

    var body: some View {
        HStack {
            Spacer()
            HStack(spacing: 8) {
                Text("플라키브 내보내기")
                    .font(.pretendard(weight: .medium500, size: 20))
                    .foregroundColor(Color(.pWhite))

                Image(systemName: "square.and.arrow.up.on.square.fill")
                    .font(.pretendard(weight: .medium500, size: 20))
                    .foregroundColor(Color(.pWhite))
            }
            .padding(EdgeInsets(top: 20, leading: 50, bottom: 20, trailing: 50))
            .background(Color(.pPrimary))
            .clipShape(RoundedRectangle(cornerRadius: 99))
            .contentShape(RoundedRectangle(cornerRadius: 99))
            .onTapGesture {
                viewModel.isDialogPresented = true
            }
            Spacer()
        }
    }
}

private struct ConfirmationDialogActions: View {
    @Environment(\.openURL) var openURL
    var viewModel: ArchivePlaylistViewModel

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
    var viewModel: ArchivePlaylistViewModel

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
                }
            }
        }
    }
}

private struct MenuContents: View {
    @Environment(ArchiveCoordinator.self) private var coord
    var viewModel: ArchivePlaylistViewModel

    var body: some View {
        Button {

        } label: {
            Label("공유하기", systemImage: "square.and.arrow.up")
        }

        Button(role: .destructive) {
            Task {
                await viewModel.deletePlaylist()
                coord.pop()
            }
        } label: {
            Label("삭제하기", systemImage: "trash")
        }
    }
}
