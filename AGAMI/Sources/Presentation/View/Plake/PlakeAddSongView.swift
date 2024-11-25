//
//  PlakeAddSongView.swift
//  AGAMI
//
//  Created by 박현수 on 11/25/24.
//

import SwiftUI
import PhotosUI

struct PlakeAddSongView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(PlakeCoordinator.self) private var coordinator
    let viewModel: PlakePlaylistViewModel
    
    var body: some View {
        ZStack(alignment: .top) {
            Color(.sWhite).ignoresSafeArea()
            
            VStack(spacing: 0) {
                TopbarItem(viewModel: viewModel)
                List {
                    Group {
                        SongStatusView(viewModel: viewModel)
                            .padding(.top, 14)
                        
                        SongListHeader()
                            .padding(.top, 53)
                    }
                    .listRowInsets(.zero)
                    .listRowSeparator(.hidden)
                    
                    SongList(viewModel: viewModel)
                        .listRowInsets(.zero)
                }
                .listStyle(.plain)
                .scrollIndicators(.hidden)
            }
        }
        .onAppearAndActiveCheckUserValued(scenePhase)
    }
}

private struct SongStatusView: View {
    let viewModel: PlakePlaylistViewModel

    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(viewModel.shazamStatus.backgroundColor)
                .padding(.horizontal, 16)
                .frame(height: 82)
                .overlay(alignment: viewModel.shazamStatus == .idle ? .center : .bottom) {
                    VStack(spacing: 0) {
                        if viewModel.shazamStatus == .searching || viewModel.shazamStatus == .moreSearching {
                            CustomLottieView(.search, speed: 0.8)
                                .frame(height: 40)
                                
                        } else if viewModel.shazamStatus == .failed {
                            Image(.shazamFailed)
                                .padding(.bottom, 13)
                        }
                        HStack(spacing: 0) {
                            if viewModel.shazamStatus == .idle || viewModel.shazamStatus == .failed {
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
                        .foregroundStyle(viewModel.shazamStatus.titleColor)
                        .padding(.bottom, viewModel.shazamStatus == .searching || viewModel.shazamStatus == .moreSearching || viewModel.shazamStatus == .failed ? 18 : 0)
                    }
                }
                .onTapGesture {
                    viewModel.simpleHaptic()
                    viewModel.searchButtonTapped()
                }
            
            Text(viewModel.shazamStatus.subTitle ?? "")
                .font(.notoSansKR(weight: .medium500, size: 14))
                .foregroundStyle(Color(.sBodyText))
        }
    }
}

private struct SongListHeader: View {
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

private struct SongList: View {
    let viewModel: PlakePlaylistViewModel

    var body: some View {
        ForEach(viewModel.playlist.songs, id: \.songID) { song in
            PlaylistRow(song: song, isHighlighted: viewModel.currentSongId == song.songID)
                .overlay(alignment: .trailing) {
                    Image(systemName: "line.3.horizontal")
                        .foregroundStyle(Color(.sSubHead))
                        .font(.system(size: 16, weight: .regular))
                        .padding(.trailing, 16)
                }
        }
        .onDelete(perform: viewModel.deleteSong)
        .onMove(perform: viewModel.moveSong)
        .padding(.horizontal, 8)
    }
}

private struct TopbarItem: View {
    @Environment(PlakeCoordinator.self) private var coordinator
    let viewModel: PlakePlaylistViewModel

    var body: some View {
        HStack(spacing: 0) {
            Button {
                viewModel.simpleHaptic()
                viewModel.stopRecognition()
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
                viewModel.simpleHaptic()
                viewModel.stopRecognition()
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
