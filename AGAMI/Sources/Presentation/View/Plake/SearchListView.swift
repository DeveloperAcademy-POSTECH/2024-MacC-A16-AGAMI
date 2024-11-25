//
//  SearchListView.swift
//  AGAMI
//
//  Created by 박현수 on 11/24/24.
//

import SwiftUI
import Kingfisher

struct SearchListView: View {
    @State var viewModel: SearchListViewModel
    @Environment(\.scenePhase) private var scenePhase

    init(viewModel: SearchListViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            SearchBar(viewModel: viewModel)
            Divider().frame(height: 0.33).background(Color(.sLine))
            if viewModel.hasNoResult {
                HasNoResultPlaceholder()
            } else {
                GeometryReader { proxy in
                    ListView(viewModel: viewModel, size: proxy.size)
                }
                .safeAreaPadding([.top, .horizontal], 16)
            }
        }
        .background(Color(.sMain))
        .navigationBarBackButtonHidden()
        .onTapGesture(perform: hideKeyboard)
        .onAppear {
            withAnimation(.easeIn(duration: 0.3)) {
                viewModel.isSearchBarPresented = true
            }
        }
        .onAppearAndActiveCheckUserValued(scenePhase)
    }
}

private struct SearchBar: View {
    @Environment(PlakeCoordinator.self) private var coordinator
    @Bindable var viewModel: SearchListViewModel
    @FocusState var isFocused: Bool

    var body: some View {
        if viewModel.isSearchBarPresented {

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
                    .focused($isFocused)
                    .foregroundStyle(Color(.sTitleText))

                    Button {
                        viewModel.clearSearchText()
                        isFocused = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color(.sButton))
                    }
                }
                .padding(7)
                .background(Color(.sSearchbar))
                .clipShape(RoundedRectangle(cornerRadius: 10))

                Button {
                    coordinator.pop()
                    viewModel.simpleHaptic()
                } label: {
                    Text("취소")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(Color(.sTitleText))
                }
            }
            .padding(EdgeInsets(top: 15, leading: 16, bottom: 15, trailing: 16))
            .background(Color(.sWhite))
            .task { isFocused = true }
            .onChange(of: isFocused) { _, newValue in
                if newValue { viewModel.simpleHaptic() }
            }
            .transition(.move(edge: .top))
        }
    }
}

private struct ListView: View {
    let viewModel: SearchListViewModel
    let size: CGSize
    private var verticalSpacingValue: CGFloat { size.width / 377 * 15 }

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: verticalSpacingValue) {
                ForEach(viewModel.playlists, id: \.playlistID) { playlist in
                    ListCell(viewModel: viewModel, playlist: playlist, size: size)
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

private struct ListCell: View {
    @Environment(PlakeCoordinator.self) private var coord
    let viewModel: SearchListViewModel
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
