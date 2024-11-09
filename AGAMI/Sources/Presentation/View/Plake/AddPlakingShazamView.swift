//
//  AddPlakingShazamView.swift
//  AGAMI
//
//  Created by 박현수 on 11/4/24.
//

import SwiftUI

struct AddPlakingShazamView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(PlakeCoordinator.self) private var coordinator
    let viewModel: AddPlakingViewModel

    var body: some View {
        ZStack {
            RadialGradient(
                colors: viewModel.shazamStatus.backgroundColor,
                center: .center,
                startRadius: 0,
                endRadius: 530
            )
            .ignoresSafeArea()

            ZStack {
                switch viewModel.shazamStatus {
                case .searching:
                    CustomLottieView(.search, speed: 1.3)
                case .failed:
                    Circle()
                        .frame(width: 234.3, height: 234.3)
                        .foregroundStyle(
                            .radialGradient(
                                colors: GradientColors.failGray,
                                center: .center,
                                startRadius: 0,
                                endRadius: 234.3
                            )
                        )
                default:
                    EmptyView()
                }

                Image(.shazamButton)
                    .onTapGesture { viewModel.searchButtonTapped() }
                    .shadow(
                        color: Color(.pBlack).opacity(0.25),
                        radius: 10, x: 0, y: 5
                    )
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
                    .onTapGesture { coordinator.pop() }
                    .padding(.top, viewModel.shazamStatus.subTitle != nil ? 160 : 200)
                    .padding(.bottom, 13)
            }
        }
        .onAppearAndActiveCheckUserValued(scenePhase)
        .navigationBarBackButtonHidden()
        .onAppear {
            viewModel.startRecognition()
        }
        .onChange(of: viewModel.shazamStatus) { _, newStatus in
            if newStatus == .found {
                coordinator.pop()
            }
        }
    }
}

#Preview {
    SearchShazamingView()
}
