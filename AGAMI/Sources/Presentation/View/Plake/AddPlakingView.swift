//
//  AddPlakingView.swift
//  AGAMI
//
//  Created by 박현수 on 11/4/24.
//

import SwiftUI

struct AddPlakingView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(PlakeCoordinator.self) private var coordinator
    @State var viewModel: AddPlakingViewModel

    init(viewModel: AddPlakingViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(.pLightGray)
                .ignoresSafeArea()

            List {
                Group {
                    PlakeTitleText(viewModel: viewModel)
                        .padding(.top, 36)

                    SearchSongListHeader(viewModel: viewModel)
                }
                .listRowSeparator(.hidden)
                .listRowInsets(.zero)
                .listRowBackground(Color(.pLightGray))

                SearchPlakeSongList(viewModel: viewModel)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 2, trailing: 0))

                Spacer()
                    .listRowSeparator(.hidden)
                    .frame(height: 50)
                    .listRowBackground(Color(.pLightGray))
            }
            .listStyle(.plain)
            .scrollIndicators(.hidden)

            ShazamButton(viewModel: viewModel)
        }
        .onAppearAndActiveCheckUserValued(scenePhase)
        .navigationTitle("플레이킹 더하기")
        .navigationBarTitleDisplayMode(.large)
        .toolbarVisibilityForVersion(.hidden, for: .tabBar)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                NavigationBackButton(viewModel: viewModel)
            }
            ToolbarItem(placement: .topBarTrailing) {
                AddPlakingButton(viewModel: viewModel)
            }
        }
        .alert(isPresented: $viewModel.showBackButtonAlert) {
            Alert(
                title: Text("플레이킹 그만두기")
                    .font(.pretendard(weight: .semiBold600, size: 16))
                    .kerning(-0.43),
                message: Text("만들던 플레이크는 사라집니다.")
                    .font(.pretendard(weight: .regular400, size: 14))
                    .kerning(-0.08),
                primaryButton: .default(Text("취소")) {
                    viewModel.showBackButtonAlert = false
                },
                secondaryButton: .destructive(Text("확인")) {
                    coordinator.pop()
                }
            )
        }
    }
}

private struct PlakeTitleText: View {
    let viewModel: AddPlakingViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("플레이크 타이틀")
                .font(.pretendard(weight: .semiBold600, size: 20))
                .foregroundStyle(Color(.pBlack))
                .padding(.leading, 16)
                .padding(.bottom, 14)

            Text(viewModel.playlist.playlistName)
                .font(.pretendard(weight: .bold700, size: 26))
                .foregroundStyle(Color(.pBlack))
                .padding(.horizontal, 16)
                .padding(.bottom, 37)
        }
    }
}

private struct SearchSongListHeader: View {
    var viewModel: AddPlakingViewModel

    var body: some View {
        HStack(spacing: 0) {
            Text("추가로 수집한 노래")
                .font(.pretendard(weight: .semiBold600, size: 20))
                .foregroundStyle(Color(.pBlack))

            Spacer()

            Text("\(viewModel.diggingList.count)곡")
                .font(.pretendard(weight: .medium500, size: 16))
                .foregroundStyle(Color(.pPrimary))
        }
        .padding(.horizontal, 16)
    }
}

private struct SearchPlakeSongList: View {
    var viewModel: AddPlakingViewModel

    var body: some View {
        ForEach(viewModel.diggingList, id: \.songID) { song in
            PlaylistRow(song: song)
        }
        .onDelete(perform: viewModel.deleteSong)
        .onMove(perform: viewModel.moveSong)
        .padding(.horizontal, 8)
    }
}

private struct NavigationBackButton: View {
    @Environment(PlakeCoordinator.self) private var coordinator
    let viewModel: AddPlakingViewModel

    var body: some View {
        Button {
            if viewModel.diggingList.isEmpty {
                coordinator.pop()
            } else {
                viewModel.showBackButtonAlert = true
            }
        } label: {
            Image(systemName: "chevron.backward")
                .font(.system(size: 17, weight: .semibold))
            Text("편집하기")
                .font(.pretendard(weight: .medium500, size: 17))
        }
        .foregroundStyle(Color(.pGray1))
    }
}

private struct AddPlakingButton: View {
    @Environment(PlakeCoordinator.self) private var coordinator
    let viewModel: AddPlakingViewModel

    var body: some View {
        Button {
            viewModel.addSongsToFirestore()
            coordinator.popToRoot()
        } label: {
            Text("완료")
                .font(.pretendard(weight: .medium500, size: 17))
                .foregroundStyle(Color(.pPrimary))
        }
    }
}

private struct ShazamButton: View {
    @Environment(PlakeCoordinator.self) private var coordinator
    let viewModel: AddPlakingViewModel

    var body: some View {
        ZStack(alignment: .bottom) {
            Button {
                coordinator.push(route: .addPlakingShazamView(viewModel: viewModel))
            } label: {
                PlakeCTAButton(type: .plaking)
                    .padding(.bottom, 26)
            }
        }
        .frame(height: 47)
        .background(Color(.pLightGray))
    }
}
