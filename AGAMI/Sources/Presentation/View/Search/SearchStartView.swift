//
//  SearchStartView.swift
//  AGAMI
//
//  Created by Seoyeon Choi on 10/15/24.
//

import SwiftUI

struct SearchStartView: View {
    @Environment(SearchCoordinator.self) var coordinator
    @State var viewModel: SearchStartViewModel = SearchStartViewModel()
    
    @State private var detent: PresentationDetent = .height(60)
    
    var body: some View {
        VStack(spacing: 0) {
            Button {
               // coordinator.presentSheet(.diggingModalView)
                viewModel.searchButtonTapped()
            } label: {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(.gray.opacity(0.3))
                    .overlay {
                        Text(viewModel.shazaming ? "서치 중" : "서치 시작")
                    }
                    .frame(width: 260, height: 100)
            }
        }
        .task {
            viewModel.isFound = false
        }
        .sheet(isPresented: .constant(true), onDismiss: {
            print("onDismiss")
            viewModel.isFound = false
        })
        {
            SearchPlaylistModalView(viewModel: viewModel, navigationTitle: "플레이크 리스트")
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .presentationDetents([.height(60), .medium, .large])
                .presentationCornerRadius(20)
                .presentationBackgroundInteraction(.enabled(upThrough: .large))
                .bottomMaskForSheet(mask: true)
        }
        .navigationTitle("Plaking")
    }
}

#Preview {
    SearchStartView(viewModel: SearchStartViewModel())
        .environment(SearchCoordinator())
}
