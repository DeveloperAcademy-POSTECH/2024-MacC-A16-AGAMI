// swiftlint:disable file_length

//
//  SologListView.swift
//  AGAMI
//
//  Created by 박현수 on 10/14/24.
//

import SwiftUI
import Kingfisher

struct SologListView: View {
    @State var viewModel: SologListViewModel = SologListViewModel()
    @Environment(UploadingDataModel.self) private var uploadingData
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
            .safeAreaPadding(.horizontal, 20)
            
            NewSologButton(viewModel: viewModel)
            
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
        .onAppearAndActiveCheckUserValued(scenePhase)
        .onAppear(perform: viewModel.fetchPlaylists)
        .onChange(of: uploadingData.shouldShowUploadingCell) { oldValue, newValue in
            if oldValue == true, newValue == false {
                viewModel.fetchPlaylists()
            }
        }
    }
}

private struct TopBarView: View {
    @Environment(SologCoordinator.self) private var coordinator
    let viewModel: SologListViewModel
    
    var body: some View {
        HStack(spacing: 12) {
            Image(.sologListIcon)
            
            Spacer()
            
            Button {
                viewModel.isSearching.toggle()
                withAnimation(.easeIn(duration: 0.2)) { viewModel.isSearchBarPresented = true }
                viewModel.simpleHaptic()
            } label: {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 22)
                        .weight(.regular))
                    .foregroundStyle(Color(.sButton))
            }
            
            Button {
                coordinator.presentSheet(.mapView(
                    viewModel: MapViewModel(playlists: viewModel.playlists)
                ))
                viewModel.simpleHaptic()
            } label: {
                Image(systemName: "map.fill")
                    .font(.system(size: 22)
                        .weight(.medium))
                    .foregroundStyle(Color(.sButton))
            }
            
            Button {
                coordinator.push(route: .accountView)
                viewModel.simpleHaptic()
            } label: {
                Image(systemName: "person.fill")
                    .font(.system(size: 22)
                        .weight(.medium))
                    .foregroundStyle(Color(.sButton))
            }
        }
        .padding(.top, 28)
    }
}

private struct CountingHeaderView: View {
    let viewModel: SologListViewModel
    
    var body: some View {
        HStack(spacing: 16) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Image(systemName: "calendar")
                    .font(.notoSansKR(weight: .regular400, size: 15))
                    .foregroundStyle(Color(.sSubHead))
                
                Text("\(viewModel.itemsCount)개")
                    .font(.notoSansKR(weight: .semiBold600, size: 17))
                    .foregroundStyle(Color(.sTitleText))
            }
            
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Image(systemName: "music.note")
                    .font(.system(size: 15))
                    .foregroundStyle(Color(.sFootNote))
                
                Text("\(viewModel.songsCount)곡")
                    .font(.notoSansKR(weight: .semiBold600, size: 17))
                    .foregroundStyle(Color(.sFootNote))
            }
            
            Spacer()
        }
        .padding(EdgeInsets(top: 24, leading: 9, bottom: 16, trailing: 9))
    }
}

private struct ListView: View {
    @Environment(SologCoordinator.self) private var coord
    @Environment(UploadingDataModel.self) private var listCellPlaceholder
    let viewModel: SologListViewModel
    let size: CGSize
    private var verticalSpacingValue: CGFloat { size.width / 377 * 15 }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: verticalSpacingValue) {
                Group {
                    if listCellPlaceholder.shouldShowUploadingCell {
                        ArchiveListUpLoadingCell(viewModel: viewModel, size: size)
                    } else if viewModel.isShowingNewSolog {
                        MakeNewSologCell(size: size)
                    }
                    
                    ForEach(viewModel.playlists, id: \.playlistID) { playlist in
                        SologListCell(playlist: playlist, size: size) {
                            viewModel.simpleHaptic()
                            coord.push(route: .playlistView(viewModel: .init(playlist: playlist)))
                        }
                        .contextMenu { ContextMenuItems(viewModel: viewModel, playlist: playlist) }
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

private struct NewSologButton: View {
    @Environment(SologCoordinator.self) private var coordinator
    let viewModel: SologListViewModel
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
    @Environment(UploadingDataModel.self) private var listCellPlaceholder
    let viewModel: SologListViewModel
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

private struct MakeNewSologCell: View {
    @Environment(SologCoordinator.self) private var coordinator
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
    let viewModel: SologListViewModel
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
            Task {
                if let spotifyURL = await viewModel.exportPlaylistToSpotify(playlist: playlist) {
                    openURL(spotifyURL)
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
    let viewModel: SologListViewModel
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
    @Environment(SologCoordinator.self) private var coordinator
    @Bindable var viewModel: SologListViewModel
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
    let viewModel: SologListViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 64.5)
            if viewModel.searchText.isEmpty {
                EmptySearchView()
            } else if viewModel.hasNoResult {
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
    @Environment(SologCoordinator.self) private var coord
    let viewModel: SologListViewModel
    let size: CGSize
    private var verticalSpacingValue: CGFloat { size.width / 377 * 15 }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: verticalSpacingValue) {
                ForEach(viewModel.filteredplaylists, id: \.playlistID) { playlist in
                    SologListCell(playlist: playlist, size: size) {
                        viewModel.simpleHaptic()
                        coord.push(route: .playlistView(viewModel: .init(playlist: playlist)))
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

private struct EmptySearchView: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
        }
    }
}
