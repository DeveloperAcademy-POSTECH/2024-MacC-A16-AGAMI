//
//  SearchShazamingView.swift
//  AGAMI
//
//  Created by Seoyeon Choi on 11/1/24.
//

import SwiftUI

struct SearchShazamingView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(PlakeCoordinator.self) private var coordinator
    @State private var viewModel: SearchShazamingViewModel = SearchShazamingViewModel()
    
    var body: some View {
        ZStack {
            ZStack {
                if viewModel.shazamStatus == .searching {
                    CustomLottieView(.search, speed: 1.3)
                }
                
                if viewModel.shazamStatus == .failed {
                    Circle()
                        .frame(width: 234.3, height: 234.3)
                        .foregroundStyle(.radialGradient(colors: GradientColors.failGray,
                                                         center: .center,
                                                         startRadius: 0,
                                                         endRadius: 234.3))
                }
                
                if viewModel.shazamStatus == .failed {
                    Image(.shazamButton)
                        .onTapGesture {
                            viewModel.searchButtonTapped()
                        }
                        .shadow(color: Color(.pBlack).opacity(0.25),
                                radius: 10,
                                x: 0,
                                y: 5)
                } else {
                    Image(.shazamButton)
                        .onTapGesture {
                            viewModel.searchButtonTapped()
                        }
                }
            }
            .padding(.bottom, 160)
            
            VStack(spacing: 0) {
                Spacer()
                
                if let title = viewModel.shazamStatus.title {
                    Text(title)
                        .font(.pretendard(weight: .semiBold600, size: 24))
                        .foregroundStyle(Color(.pPrimary))
                        .padding(.bottom, viewModel.shazamStatus.subTitle != nil ? 14 : 0)
                }
                
                if let subTitle = viewModel.shazamStatus.subTitle {
                    Text(subTitle)
                        .font(.pretendard(weight: .medium500, size: 20))
                        .foregroundStyle(Color(.pPrimary))
                }
                
                PlakeCTAButton(type: .cancel)
                    .onTapGesture {
                        coordinator.pop()
                    }
                    .padding(.top, viewModel.shazamStatus.subTitle != nil ? 160 : 200)
                    .padding(.bottom, 13)
            }
        }
        .onAppearAndActiveCheckUserValued(scenePhase)
        .navigationBarBackButtonHidden()
        .onAppear(perform: viewModel.startRecognition)
        .onDisappear(perform: viewModel.stopRecognition)
        .onChange(of: viewModel.shazamStatus) { _, newStatus in
            if newStatus == .found {
                coordinator.pop()
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background {
                viewModel.shazamStatus = .failed
                viewModel.stopRecognition()
            }
        }
    }
}

#Preview {
    SearchShazamingView()
}
