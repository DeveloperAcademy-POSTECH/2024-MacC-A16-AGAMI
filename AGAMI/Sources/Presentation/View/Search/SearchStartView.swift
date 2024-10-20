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
        .onAppear {
            coordinator.presentSheet(.diggingModalView(viewModel: viewModel),
                                     onDismiss: { viewModel.shazamStatus = .idle })
        }
        .onDisappear {
            coordinator.dismissSheet()
        }
        .navigationTitle("Plaking")
    }
}

#Preview {
    SearchStartView(viewModel: SearchStartViewModel())
        .environment(SearchCoordinator())
}
