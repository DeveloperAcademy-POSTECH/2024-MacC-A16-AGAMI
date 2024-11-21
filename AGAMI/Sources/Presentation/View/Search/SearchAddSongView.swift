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
    @State var viewModel: SearchAddSongViewModel
    
    init(viewModel: SearchAddSongViewModel) {
        _viewModel = State(initialValue: viewModel)
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Color(.sWhite).ignoresSafeArea()
            
            VStack(spacing: 0) {
                TopbarItem()
                List {
                    Group {
                        SearchSongStatusView(viewModel: viewModel)
                            .padding(.top, 14)
                        
                        SearchSongListHeader()
                            .padding(.top, 53)
                    }
                    .listRowInsets(.zero)
                    .listRowSeparator(.hidden)
                    
                    SearchSongList(viewModel: viewModel)
                        .listRowInsets(.zero)
                }
                .listStyle(.plain)
                .scrollIndicators(.hidden)
            }
        }
        .onAppearAndActiveCheckUserValued(scenePhase)
    }
}

private struct SearchSongStatusView: View {
    let viewModel: SearchAddSongViewModel
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.sShazam))
                .padding(.horizontal, 16)
                .frame(height: 82)
                .overlay {
                    HStack(spacing: 0) {
                        if viewModel.shazamStatus == .idle {
                            Image(systemName: "plus")
                                .font(.system(size: 10, weight: .semibold))
                            Image(systemName: "music.note")
                                .font(.system(size: 17, weight: .light))
                                .padding(.leading, -4)
                        }
                        Text(viewModel.shazamStatus.title ?? "")
                            .font(.notoSansKR(weight: .medium500, size: 17))
                            .padding(.leading, 6)
                    }
                    .foregroundStyle(Color(.sTitleText))
                }
                .onTapGesture {
                    viewModel.searchButtonTapped()
                }
            
            Text(viewModel.shazamStatus.subTitle ?? "")
                .font(.notoSansKR(weight: .medium500, size: 14))
                .foregroundStyle(Color(.sBodyText))
        }
    }
}

private struct SearchSongListHeader: View {
    var body: some View {
        HStack(spacing: 0) {
            Text("수집한 항목")
                .font(.notoSansKR(weight: .semiBold600, size: 20))
                .foregroundStyle(Color(.sTitleText))
            
            Spacer()
        }
        .padding(.leading, 16)
        .padding(.bottom, 16)
    }
}
private struct SearchSongList: View {
    let viewModel: SearchAddSongViewModel
    
    var body: some View {
        ForEach(viewModel.diggingList, id: \.songID) { song in
            PlaylistRow(song: song, isHighlighted: viewModel.currentSongId == song.songID)
        }
        .padding(.horizontal, 8)
    }
}

private struct TopbarItem: View {
    @Environment(PlakeCoordinator.self) private var coordinator
    
    var body: some View {
        HStack(spacing: 0) {
            Button {
                coordinator.dismissSheet()
            } label: {
                Text("닫기")
                    .font(.notoSansKR(weight: .regular400, size: 17))
                    .foregroundStyle(Color(.sButton))
            }
            .frame(width: 48, height: 39)
            
            Spacer()
            
            Text("기록에 음악 추가")
                .font(.notoSansKR(weight: .semiBold600, size: 20))
                .foregroundStyle(Color(.sTitleText))
            
            Spacer()
            
            Button {
                coordinator.dismissSheet()
            } label: {
                Text("완료")
                    .font(.notoSansKR(weight: .regular400, size: 17))
                    .foregroundStyle(Color(.sButton))
            }
            .frame(width: 48, height: 39)
        }
        .padding(8)
    }
}
