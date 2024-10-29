//
//  SearchStartView.swift
//  AGAMI
//
//  Created by Seoyeon Choi on 10/15/24.
//

import SwiftUI

import Lottie

struct SearchStartView: View {
    @Environment(SearchCoordinator.self) var coordinator
    @State var viewModel: SearchStartViewModel = SearchStartViewModel()
    
    var body: some View {
        ZStack {
            Color(viewModel.shazamStatus.backgroundColor)
                .ignoresSafeArea(edges: .top)
            
            if viewModel.shazamStatus == .searching {
                CustomLottieView(.search)
                    .ignoresSafeArea()
            }
            
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Image(.plakeLogo)
                        .padding(.top, 24)
                        .padding(.leading, 24)
                    
                    Spacer()
                }
                .padding(.bottom, 68)
                
                Image(.diggingButtonBackground)
                    .resizable()
                    .frame(width: 393, height: 393)
                    .overlay {
                        Button {
                            viewModel.searchButtonTapped()
                        } label: {
                            Image(.diggingButton)
                                .resizable()
                                .frame(width: 85, height: 85)
                        }
                        
                    }
                
                VStack(spacing: 5) {
                    if let title = viewModel.shazamStatus.title {
                        Text(title)
                            .font(.pretendard(weight: .semiBold600, size: 24))
                            .foregroundStyle(.white)
                    }
                    
                    if let subTitle = viewModel.shazamStatus.subTitle {
                        Text(subTitle)
                            .font(.pretendard(weight: .medium500, size: 20))
                            .foregroundStyle(.white)
                    }
                }
                .padding(.top, -50)
                
                Spacer()
            }
        }
        .onAppear {
            coordinator.presentSheet(.diggingModalView(viewModel: viewModel),
                                     onDismiss: { viewModel.shazamStatus = .idle })
        }
        .onDisappear {
            coordinator.dismissSheet()
        }
    }
}

#Preview {
    SearchStartView(viewModel: SearchStartViewModel())
        .environment(SearchCoordinator())
}
