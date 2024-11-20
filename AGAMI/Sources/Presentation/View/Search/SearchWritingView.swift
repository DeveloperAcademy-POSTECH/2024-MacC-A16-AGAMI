//
//  SearchWritingView.swift
//  AGAMI
//
//  Created by Seoyeon Choi on 10/15/24.
//

import SwiftUI

struct SearchWritingView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(PlakeCoordinator.self) private var coordinator
    @State private var viewModel: SearchWritingViewModel = SearchWritingViewModel()
    
    var body: some View {
        ZStack(alignment: .top) {
            Color(.sMain)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                SearchTitleTextField(viewModel: viewModel)
                    .padding(.top, 7)
                
                SearchDescriptionTextField(viewModel: viewModel)
                    .padding(.top, 24)
                
                Spacer()
                
                SearchAddButton(viewModel: viewModel)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .ignoresSafeArea(.keyboard)
        .onAppearAndActiveCheckUserValued(scenePhase)
        .onTapGesture(perform: hideKeyboard)
        .navigationBarBackButtonHidden(true)
        .photosPicker(isPresented: $viewModel.showPhotoPicker,
                      selection: $viewModel.selectedItem,
                      matching: .images)
        .onChange(of: viewModel.selectedItem) {
            Task {
                await viewModel.loadImageFromGallery()
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                ToolbarLeadingItem(viewModel: viewModel)
            }
            ToolbarItem(placement: .topBarTrailing) {
                ToolabraTrailingItem(viewModel: viewModel)
            }
        }
    }
}

private struct SearchTitleTextField: View {
    @Bindable var viewModel: SearchWritingViewModel
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("오늘의 기록")
                .font(.notoSansKR(weight: .regular400, size: 15))
                .foregroundStyle(Color(.sSubHead))
                .padding(.bottom, 6)
            
            HStack(spacing: 0) {
                TextField("타이틀 입력", text: $viewModel.playlist.playlistName)
                    .font(.sCoreDream(weight: .dream5, size: 24))
                    .foregroundStyle(Color(.sTitleText))
                    .tint(Color(.sTitleText))
                    .focused($isFocused)
                    .background(Color(.sMain))
                
                Text("15/15")
                    .font(.notoSansKR(weight: .regular400, size: 13))
                    .foregroundStyle(Color(.sTextCaption))
            }
            .padding(.bottom, 6)
            
            Divider()
                .frame(height: 0.5)
                .foregroundStyle(Color(.sLine))
        }
        .padding(.horizontal, 20)
    }
}

private struct SearchDescriptionTextField: View {
    @Bindable var viewModel: SearchWritingViewModel
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            TextField("기록하고 싶었던 순간이나 생각과 감정을 작성해보세요.",
                      text: $viewModel.playlist.playlistDescription,
                      axis: .vertical)
            .font(.notoSansKR(weight: .regular400, size: 15))
            .background(Color(.sMain))
        }
        .padding(.horizontal, 20)
    }
}

private struct SearchAddButton: View {
    @Environment(PlakeCoordinator.self) private var coordinator
    let viewModel: SearchWritingViewModel
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            Spacer()
            
            Label {
                Text("사진 추가")
                    .font(.notoSansKR(weight: .semiBold600, size: 15))
            } icon: {
                Image(systemName: "photo")
                    .font(.system(size: 17, weight: .regular))
            }
            .onTapGesture {
                viewModel.showPhotoPicker.toggle()
            }
            
            Spacer()
            
            Divider()
                .frame(width: 0.5, height: 20)
                .foregroundStyle(Color(.sLine))
            
            Spacer()
            
            Label {
                Text("음악 추가")
                    .font(.notoSansKR(weight: .semiBold600, size: 15))
            } icon: {
                Image(systemName: "music.note")
                    .font(.system(size: 17, weight: .regular))
            }
            .onTapGesture {
                let searchAddSongViewModel = viewModel.createSearchAddSongViewModel()
                coordinator.presentSheet(.searchAddSongView(viewModel: searchAddSongViewModel))
            }
            
            Spacer()
        }
        .padding(.top, 20)
        .padding(.bottom, 51)
        .foregroundStyle(Color(.sButton))
        .background(Color(.sWhite))
    }
}

private struct ToolbarLeadingItem: View {
    @Environment(PlakeCoordinator.self) private var coordinator
    var viewModel: SearchWritingViewModel
    
    var body: some View {
        Button {
            coordinator.pop()
        } label: {
            Image(systemName: "chevron.backward")
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(Color(.sButton))
        }
    }
}

private struct ToolabraTrailingItem: View {
    @Environment(PlakeCoordinator.self) private var coordinator
    var viewModel: SearchWritingViewModel
    
    var body: some View {
        Button {
            // 저장
        } label: {
            Text("저장")
                .font(.pretendard(weight: .medium500, size: 17))
                .foregroundStyle(viewModel.saveButtonEnabled ? Color(.sButton) : Color(.sButtonDisabled))
        }
        .disabled(viewModel.saveButtonEnabled)
    }
}

#Preview {
    SearchWritingView()
}
