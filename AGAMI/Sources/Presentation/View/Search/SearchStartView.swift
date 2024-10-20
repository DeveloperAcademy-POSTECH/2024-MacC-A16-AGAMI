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

    var body: some View {
        VStack(spacing: 0) {
            Button {
                viewModel.searchButtonTapped()
            } label: {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(.gray.opacity(0.3))
                    .overlay {
                        Text(viewModel.shazamStatus.buttonDescription)
                    }
                    .frame(width: 260, height: 100)
            }
        }
        .task {
            viewModel.showSheet = true
        }
        .sheet(isPresented: $viewModel.showSheet, onDismiss: {
            viewModel.shazamStatus = .idle
        }) {
            SearchPlaylistModalView(viewModel: viewModel)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .presentationDetents([.height(60), .medium, .large])
                .presentationCornerRadius(20)
                .presentationBackgroundInteraction(.enabled(upThrough: .large))
                .interactiveDismissDisabled()
                .bottomMaskForSheet()
        }
        .navigationTitle("Plaking")
    }
}

#Preview {
    SearchStartView(viewModel: SearchStartViewModel())
        .environment(SearchCoordinator())
}
