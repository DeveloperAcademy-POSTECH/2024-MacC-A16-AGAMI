//
//  SearchStartView.swift
//  AGAMI
//
//  Created by Seoyeon Choi on 10/15/24.
//

import SwiftUI

struct SearchStartView: View {
    @Environment(SearchCoordinator.self) var coordinator
    var viewModel: SearchStartViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            Button {
                coordinator.presentSheet(.playlistModalView)
                viewModel.searchButtonTapped()
            } label: {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(.gray.opacity(0.3))
                    .overlay {
                        Text("서치 시작")
                    }
                    .frame(width: 260, height: 100)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing, content: {
                Button {
                    coordinator.push(view: .writingView)
                } label: {
                    Text("다음")
                }
            })
        }
        .navigationTitle("Search")
    }
}

#Preview {
    SearchStartView(viewModel: SearchStartViewModel())
        .environment(SearchCoordinator())
}
