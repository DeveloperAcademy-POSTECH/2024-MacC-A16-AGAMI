//
//  SearchStartView.swift
//  AGAMI
//
//  Created by Seoyeon Choi on 10/15/24.
//

import SwiftUI

struct SearchStartView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(PlakeCoordinator.self) private var coordinator
    @State private var viewModel: SearchStartViewModel = SearchStartViewModel()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color(.pLightGray)
                .ignoresSafeArea()
            
            List {
                SearchPlakeTitleTextField(viewModel: viewModel)
                    .listRowSeparator(.hidden)
                    .listRowInsets(.zero)
                    .listRowBackground(Color(.pLightGray))
                    .padding(.top, 36)
                
                SearchSongListHeader(viewModel: viewModel)
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
            
            ZStack(alignment: .bottom) {
                Button {
                    coordinator.push(route: .searchShazamingView)
                } label: {
                    PlakeCTAButton(type: .plaking)
                        .padding(.bottom, 26)
                }
            }
            .frame(height: 47)
            .background(Color(.pLightGray))
        }
        .ignoresSafeArea(.keyboard)
        .onAppearAndActiveCheckUserValued(scenePhase)
        .onAppear {
            viewModel.initializeView()
        }
        .onTapGesture {
            hideKeyboard()
        }
        .navigationTitle("새로운 플레이크")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    if viewModel.diggingList.isEmpty {
                        viewModel.showBackButtonAlert = false
                        coordinator.pop()
                    } else {
                        viewModel.showBackButtonAlert = true
                    }
                } label: {
                    Image(systemName: "chevron.backward")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color(.pPrimary))
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                let nextButtonDisabled = viewModel.diggingList.isEmpty || !viewModel.isLoaded
                Button {
                    let searchWritingViewModel = viewModel.createSearchWritingViewModel()
                    coordinator.push(route: .searchWritingView(viewModel: searchWritingViewModel))
                } label: {
                    Text("다음")
                        .font(.pretendard(weight: .medium500, size: 17))
                        .foregroundStyle(nextButtonDisabled ? Color(.pGray1) : Color(.pPrimary))
                }
                .disabled(nextButtonDisabled)
            }
        }
        .alert(isPresented: $viewModel.showBackButtonAlert) {
            Alert(
                title: Text("플레이크 그만두기")
                    .font(.pretendard(weight: .semiBold600, size: 16))
                    .kerning(-0.43),
                message: Text("만들던 플레이크는 사라집니다.")
                    .font(.pretendard(weight: .regular400, size: 14))
                    .kerning(-0.08),
                primaryButton: .default(Text("취소")) {
                    viewModel.showBackButtonAlert = false
                },
                secondaryButton: .destructive(Text("확인")) {
                    viewModel.clearDiggingList()
                    coordinator.pop()
                }
            )
        }
    }
}

private struct SearchPlakeTitleTextField: View {
    @Bindable var viewModel: SearchStartViewModel
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("플레이크 타이틀")
                .font(.pretendard(weight: .semiBold600, size: 20))
                .foregroundStyle(Color(.pBlack))
                .padding(.leading, 16)
                .padding(.bottom, 14)
            
            TextField("\(viewModel.placeHolderAddress)", text: $viewModel.userTitle)
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
                .padding(.horizontal, 8)
                .padding(.bottom, 37)
        }
    }
}

private struct SearchSongListHeader: View {
    var viewModel: SearchStartViewModel
    
    var body: some View {
        HStack(spacing: 0) {
            Text("수집한 노래")
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
    var viewModel: SearchStartViewModel
    
    var body: some View {
        ForEach(viewModel.diggingList, id: \.songID) { song in
            PlaylistRow(song: song)
        }
        .onDelete(perform: viewModel.deleteSong)
        .onMove(perform: viewModel.moveSong)
        .padding(.horizontal, 8)
    }
}

#Preview {
    SearchStartView()
}
