// swiftlint:disable file_length

//
//  PlakeListView.swift
//  AGAMI
//
//  Created by 박현수 on 10/14/24.
//

import SwiftUI
import Kingfisher

struct PlakeListView: View {
    @State var viewModel: PlakeListViewModel = PlakeListViewModel()
    @Environment(ListCellPlaceholderModel.self) private var listCellPlaceholder
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                TopBarView(viewModel: viewModel)
                CountingHeaderView(viewModel: viewModel)
                GeometryReader { proxy in
                    ListView(viewModel: viewModel, size: proxy.size)
                }
            }
            .safeAreaPadding(.horizontal, 16)

            NewPlakeButton(viewModel: viewModel)

            switch viewModel.exportingState {
            case .isAppleMusicExporting:
                AppleMusicLottieView()
            case .isSpotifyExporting:
                SpotifyLottieView()
            case .none:
                EmptyView()
            }

            if viewModel.isFetching { ProgressView() }

            SearchView(viewModel: viewModel)
        }
        .background(Color(.sMain))
        .toolbarBackground(.visible, for: .tabBar)
        .refreshable { viewModel.fetchPlaylists() }
        .onTapGesture(perform: hideKeyboard)
        .onOpenURL { viewModel.handleURL($0) }
        .onAppearAndActiveCheckUserValued(scenePhase)
        .onAppear(perform: viewModel.fetchPlaylists)
        .onChange(of: listCellPlaceholder.shouldShowUploadingCell) { oldValue, newValue in
            if oldValue == true, newValue == false {
                viewModel.fetchPlaylists()
            }
        }
    }
}

private struct TopBarView: View {
    @Environment(PlakeCoordinator.self) private var coordinator
    let viewModel: PlakeListViewModel

    var body: some View {
        HStack(spacing: 8) {
            HStack(spacing: 5) {
                Image(.sologListIcon)
                Text("소록")
                    .font(.sCoreDream(weight: .dream6, size: 27))
                    .foregroundStyle(Color(.sTitleText))
                    .kerning(-0.22)
            }

            Spacer()

            Button {
                viewModel.isSearching.toggle()
                withAnimation(.easeIn(duration: 0.2)) { viewModel.isSearchBarPresented = true }
                viewModel.simpleHaptic()
            } label: {
                Image(systemName: "magnifyingglass.circle")
                    .font(.system(size: 26)
                        .weight(.light))
                    .foregroundStyle(Color(.sButton))
            }

            Button {
                coordinator.presentSheet(.mapView(
                    viewModel: MapViewModel(playlists: viewModel.playlists)
                ))
                viewModel.simpleHaptic()
            } label: {
                Image(systemName: "map.circle")
                    .font(.system(size: 26)
                        .weight(.light))
                    .foregroundStyle(Color(.sButton))
            }

            Button {
                coordinator.presentSheet(.accountView)
                viewModel.simpleHaptic()
            } label: {
                Image(systemName: "person.circle")
                    .font(.system(size: 26)
                        .weight(.light))
                    .foregroundStyle(Color(.sButton))
            }
        }
        .padding(.top, 28)
    }
}

private struct CountingHeaderView: View {
    let viewModel: PlakeListViewModel

    var body: some View {
        HStack(spacing: 16) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Image(systemName: "calendar")
                    .font(.notoSansKR(weight: .regular400, size: 15))
                    .foregroundStyle(Color(.sSubHead))
                    .padding(.horizontal, 4)

                VStack(alignment: .leading, spacing: 0) {
                    Text("순간의 소록")
                        .font(.notoSansKR(weight: .regular400, size: 15))
                        .foregroundStyle(Color(.sSubHead))
                    Text("\(viewModel.itemsCount)개")
                        .font(.notoSansKR(weight: .semiBold600, size: 17))
                        .foregroundStyle(Color(.sTitleText))
                }
            }

            Divider()
                .frame(width: 0.5, height: 40)
                .background(Color(.sLine))

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Image(systemName: "music.note")
                    .font(.system(size: 15))
                    .foregroundStyle(Color(.sSubHead))
                    .padding(.horizontal, 4)

                VStack(alignment: .leading, spacing: 0) {
                    Text("수집한 음악")
                        .font(.notoSansKR(weight: .regular400, size: 15))
                        .foregroundStyle(Color(.sSubHead))
                    Text("\(viewModel.songsCount)곡")
                        .font(.notoSansKR(weight: .semiBold600, size: 17))
                        .foregroundStyle(Color(.sTitleText))
                }
            }

            Spacer()
        }
        .fixedSize(horizontal: false, vertical: true)
        .frame(height: 40)
        .padding(EdgeInsets(top: 24, leading: 0, bottom: 16, trailing: 0))
    }
}

private struct ListView: View {
    @Environment(ListCellPlaceholderModel.self) private var listCellPlaceholder
    let viewModel: PlakeListViewModel
    let size: CGSize
    private var verticalSpacingValue: CGFloat { size.width / 377 * 15 }

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: verticalSpacingValue) {
                Group {
                    if listCellPlaceholder.shouldShowUploadingCell {
                        ArchiveListUpLoadingCell(viewModel: viewModel, size: size)
                    } else if viewModel.isShowingNewPlake {
                        MakeNewPlakeCell(size: size)
                    }

                    ForEach(viewModel.playlists, id: \.playlistID) { playlist in
                        PlakeListCell(viewModel: viewModel, playlist: playlist, size: size)
                    }
                }
                .scrollTransition(.animated, axis: .vertical) { content, phase in
                    content
                        .scaleEffect(phase.isIdentity ? 1 : 0.8)
                        .opacity(phase.isIdentity ? 1 : 0.5)
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned(limitBehavior: getAlwaysByOneIfAvailableElseAlways()))
    }
}

private struct PlakeListCell: View {
    @Environment(PlakeCoordinator.self) private var coord
    let viewModel: PlakeListViewModel
    let playlist: PlaylistModel
    let size: CGSize
    private var imageHeight: CGFloat { (size.width - 20) * 157 / 341 }

    var body: some View {
        Button {
            viewModel.simpleHaptic()
            coord.push(route: .playlistView(viewModel: .init(playlist: playlist)))
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                KFImage(URL(string: playlist.photoURL))
                    .resizable()
                    .cancelOnDisappear(true)
                    .placeholder {
                        Image(.sologPlaceholder)
                            .resizable()
                    }
                    .scaledToFill()
                    .frame(height: imageHeight)
                    .clipped()
                    .padding(.vertical, 15)

                Text(playlist.playlistName)
                    .font(.sCoreDream(weight: .dream5, size: 20))
                    .foregroundStyle(Color(.sTitleText))

                Divider()
                    .frame(height: 0.5)
                    .foregroundStyle(Color(.sLine))
                    .padding(.bottom, 6)

                HStack(spacing: 0) {
                    Text(Image(systemName: "music.note"))
                        .font(.system(size: 15))
                        .foregroundStyle(Color(.sSubHead))
                        .padding(.trailing, 2)
                    Text("수집한 음악")
                        .font(.notoSansKR(weight: .regular400, size: 15))
                        .foregroundStyle(Color(.sSubHead))
                        .padding(.trailing, 8)
                    Text("\(playlist.songs.count)곡")
                        .font(.notoSansKR(weight: .medium500, size: 15))
                        .foregroundStyle(Color(.sTitleText))
                }

                Divider()
                    .frame(height: 0.5)
                    .foregroundStyle(Color(.sLine))
                    .padding(.vertical, 6)

                Text("\(viewModel.formatDateToString(playlist.generationTime))")
                    .font(.notoSansKR(weight: .regular400, size: 12))
                    .foregroundStyle(Color(.sFootNote))
                    .padding(.bottom, 10)
            }
            .padding(.horizontal, 10)
            .background(Color(.sWhite))
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .shadow(color: Color(.sBlack).opacity(0.15), radius: 3, x: 0, y: 1)
        }
        .contextMenu { ContextMenuItems(viewModel: viewModel, playlist: playlist) }
    }
}

private struct NewPlakeButton: View {
    @Environment(PlakeCoordinator.self) private var coordinator
    let viewModel: PlakeListViewModel
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button {
                    coordinator.push(route: .searchWritingView)
                    viewModel.simpleHaptic()
                } label: {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Color(.sMain))
                        .padding(10)
                        .background(Color(.sButton))
                        .clipShape(Circle())
                        .overlay(
                            Circle().stroke(Color(.sMain), lineWidth: 2)
                        )
                }
                .padding(EdgeInsets(top: 16, leading: 30, bottom: 16, trailing: 30))
            }
            .ignoresSafeArea()
            .background(viewModel.playlists.count > 1 ? .clear : Color(.sMainTab))
        }
    }
}

private struct ArchiveListUpLoadingCell: View {
    @Environment(ListCellPlaceholderModel.self) private var listCellPlaceholder
    let viewModel: PlakeListViewModel
    let size: CGSize
    private var imageHeight: CGFloat { (size.width - 20) * 157 / 341 }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Image(.sologPlaceholder)
                .resizable()
                .scaledToFill()
                .frame(height: imageHeight)
                .padding(.vertical, 15)

            Text(listCellPlaceholder.name ?? "")
                .font(.sCoreDream(weight: .dream5, size: 20))
                .foregroundStyle(Color(.sTitleText))

            Divider()
                .frame(height: 0.5)
                .foregroundStyle(Color(.sLine))
                .padding(.bottom, 6)

            HStack(spacing: 10) {
                Text("업로드 중")
                    .font(.notoSansKR(weight: .regular400, size: 15))
                    .foregroundStyle(Color(.sSubHead))
                CircleAnimationView()
            }

            Divider()
                .frame(height: 0.5)
                .foregroundStyle(Color(.sLine))
                .padding(.vertical, 6)

            Text("\(viewModel.formatDateToString(listCellPlaceholder.generationTime ?? Date()))")
                .font(.notoSansKR(weight: .regular400, size: 12))
                .foregroundStyle(Color(.sFootNote))
                .padding(.bottom, 10)
        }
        .padding(.horizontal, 10)
        .background(Color(.sWhite))
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .shadow(color: Color(.sBlack).opacity(0.15), radius: 3, x: 0, y: 1)
    }
}

private struct MakeNewPlakeCell: View {
    @Environment(PlakeCoordinator.self) private var coordinator
    let size: CGSize
    private var imageHeight: CGFloat { (size.width - 20) * 157 / 341 }

    var body: some View {
        Button {
            coordinator.push(route: .searchWritingView)
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                Image(.sologPlaceholder)
                    .resizable()
                    .scaledToFill()
                    .clipped()
                    .frame(height: imageHeight)
                    .padding(.vertical, 15)

                Text("지금 들려오는 음악과 함께,")
                    .font(.sCoreDream(weight: .dream5, size: 20))
                    .foregroundStyle(Color(.sTitleText))

                Divider()
                    .frame(height: 0.5)
                    .foregroundStyle(Color(.sLine))
                    .padding(.bottom, 6)

                Text("순간의 소록을 시작해보세요.")
                    .font(.sCoreDream(weight: .dream5, size: 17))
                    .foregroundStyle(Color(.sTitleText))

                Divider()
                    .frame(height: 0.5)
                    .foregroundStyle(Color(.sLine))
                    .padding(.vertical, 6)

                Text("언제, 어디서나 소록.")
                    .font(.notoSansKR(weight: .regular400, size: 12))
                    .foregroundStyle(Color(.sFootNote))
                    .padding(.bottom, 10)
            }
            .padding(.horizontal, 10)
            .background(Color(.sWhite))
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .shadow(color: Color(.sBlack).opacity(0.15), radius: 3, x: 0, y: 1)
        }
    }
}

private struct ContextMenuItems: View {
    @Environment(\.openURL) private var openURL
    let viewModel: PlakeListViewModel
    let playlist: PlaylistModel

    var body: some View {
        Button {
            Task {
                if let appleMusicURL = await viewModel.exportPlaylistToAppleMusic(playlist: playlist) {
                    openURL(appleMusicURL)
                }
            }
        } label: {
            Label("Apple Music에서 열기", systemImage: "square.and.arrow.up")
        }
        Button {
            viewModel.exportPlaylistToSpotify(playlist: playlist) { result in
                switch result {
                case .success(let url):
                    openURL(url)
                case .failure(let err):
                    dump(err.localizedDescription)
                }
            }
        } label: {
            Label("Spotify에서 열기", systemImage: "square.and.arrow.up")
        }
        Button(role: .destructive) {
            viewModel.deletePlaylist(playlistID: playlist.playlistID, photoURL: playlist.photoURL)
        } label: {
            Label("삭제", systemImage: "trash")
        }
    }
}

private struct SearchView: View {
    let viewModel: PlakeListViewModel
    @FocusState private var isFocused
    var body: some View {
        ZStack(alignment: .top) {
            if viewModel.isSearching {
                SearchResultView(viewModel: viewModel)
            }

            if viewModel.isSearchBarPresented {
                SearchBar(viewModel: viewModel, isFocused: $isFocused)
                    .transition(.move(edge: .top))
            }
        }
    }
}

private struct SearchBar: View {
    @Environment(PlakeCoordinator.self) private var coordinator
    @Bindable var viewModel: PlakeListViewModel
    var isFocused: FocusState<Bool>.Binding

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Text("\(Image(systemName: "magnifyingglass")) ")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(Color(.sTitleText))

                TextField(
                    "",
                    text: $viewModel.searchText,
                    prompt: Text("검색").foregroundStyle(Color(.sTitleText))
                )
                .font(.system(size: 17, weight: .regular))
                .focused(isFocused)
                .foregroundStyle(Color(.sTitleText))

                Button {
                    viewModel.clearSearchText()
                    isFocused.wrappedValue = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color(.sButton))
                }
            }
            .padding(7)
            .background(Color(.sSearchbar))
            .clipShape(RoundedRectangle(cornerRadius: 10))

            Button {
                withAnimation(.easeIn(duration: 0.2)) { viewModel.isSearchBarPresented = false }
                isFocused.wrappedValue = false
                viewModel.isSearching.toggle()
                viewModel.simpleHaptic()
            } label: {
                Text("취소")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(Color(.sTitleText))
            }
        }
        .padding(EdgeInsets(top: 15, leading: 16, bottom: 15, trailing: 16))
        .background(Color(.sWhite))
        .task { isFocused.wrappedValue = true }
        .onChange(of: isFocused.wrappedValue) { _, newValue in
            if newValue { viewModel.simpleHaptic() }
        }
        .transition(.move(edge: .top))
    }
}

private struct SearchResultView: View {
    @Environment(\.scenePhase) private var scenePhase
    let viewModel: PlakeListViewModel

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 64.5)
            if viewModel.hasNoResult {
                HasNoResultPlaceholder()
            } else {
                GeometryReader { proxy in
                    SearchResultListView(viewModel: viewModel, size: proxy.size)
                }
                .safeAreaPadding([.top, .horizontal], 16)
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color(.sMain))
        .onTapGesture(perform: hideKeyboard)
    }
}

private struct SearchResultListView: View {
    let viewModel: PlakeListViewModel
    let size: CGSize
    private var verticalSpacingValue: CGFloat { size.width / 377 * 15 }

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: verticalSpacingValue) {
                ForEach(viewModel.filteredplaylists, id: \.playlistID) { playlist in
                    PlakeListCell(viewModel: viewModel, playlist: playlist, size: size)
                }
                .scrollTransition(.animated, axis: .vertical) { content, phase in
                    content
                        .scaleEffect(phase.isIdentity ? 1 : 0.8)
                        .opacity(phase.isIdentity ? 1 : 0.5)
                }
            }
            .scrollTargetLayout()
        }
        .scrollDismissesKeyboard(.immediately)
        .scrollTargetBehavior(.viewAligned(limitBehavior: getAlwaysByOneIfAvailableElseAlways()))
    }
}

private struct HasNoResultPlaceholder: View {
    var body: some View {
        VStack(spacing: 10) {
            Spacer()
            Text("결과 없음")
                .font(.notoSansKR(weight: .semiBold600, size: 24))
                .foregroundStyle(Color(.sTitleText))
            Text("검색어를 확인해보세요.")
                .font(.notoSansKR(weight: .regular400, size: 17))
                .foregroundStyle(Color(.sSubHead))
            Spacer()
        }
    }
}
