//
//  SearchWritingView.swift
//  AGAMI
//
//  Created by Seoyeon Choi on 10/16/24.
//

import SwiftUI

struct SearchWritingView: View {
    @Environment(SearchCoordinator.self) var coordinator
    @State var viewModel: SearchWritingViewModel = SearchWritingViewModel()

    var body: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 10)
                .padding(24)
                .frame(height: 345)
                .foregroundStyle(.gray)
                .shadow(color: Color.black.opacity(0.25), radius: 8, x: 0, y: 4)
            
            VStack(alignment: .leading, spacing: 0) {
                TextField("타이틀을 입력하세요", text: $viewModel.userTitle)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 24)
                
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(.gray.opacity(0.2))
                    .overlay(alignment: .topLeading) {
                        TextField("텍스트 기록 남기기", text: $viewModel.userDescription, axis: .vertical)
                            .background(.clear)
                            .foregroundStyle(.black)
                            .padding()
                    }
                    .frame(height: 168)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 13)
            }
            
            Button(action: {
                viewModel.showPlaylistButtonTapped()
            }, label: {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(.gray.opacity(0.3))
                    .overlay {
                        Text("플리 목록 보기")
                    }
                    .frame(width: 260, height: 100)
            })
        }
        .onTapGesture {
            hideKeyboard()
        }
        .sheet(isPresented: $viewModel.showPlaylistModal, content: {
            coordinator.buildSheet(sheet: .diggingModalView)
        })
        .navigationTitle("타이틀")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing, content: {
                Button(action: {
                    coordinator.push(view: .cameraView)
                }, label: {
                    Text("완료")
                })
            })
        }
    }
}

#Preview {
    SearchWritingView()
}
