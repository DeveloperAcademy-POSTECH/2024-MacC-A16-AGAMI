//
//  SearchShazamingView.swift
//  AGAMI
//
//  Created by Seoyeon Choi on 11/1/24.
//

import SwiftUI

struct SearchShazamingView: View {
    @State private var viewModel: SearchShazamingViewModel = SearchShazamingViewModel()
    
    var body: some View {
        ZStack {
            Color(viewModel.shazamStatus.backgroundColor)
                .ignoresSafeArea()
                
            VStack(spacing: 0) {
                Spacer()
                
                ZStack {
                    Image(.diggingButtonBackground)
                    if viewModel.shazamStatus == .searching {
                        CustomLottieView(.search)
                            .ignoresSafeArea()
                    }
                    
                    Button {
                        viewModel.searchButtonTapped()
                    } label: {
                        Image(.shazamButton)
                    }
                }
                if let title = viewModel.shazamStatus.title {
                    Text(title)
                        .font(.pretendard(weight: .semiBold600, size: 24))
                        .foregroundStyle(Color(.pWhite))
                }
                
                if let subTitle = viewModel.shazamStatus.subTitle {
                    Text(subTitle)
                        .font(.pretendard(weight: .medium500, size: 20))
                        .foregroundStyle(Color(.pWhite))
                }
                
                Spacer()
                PlakeCTAButton(type: .cancel)
                .padding(.bottom, 26)
            }
        }
    }
}

#Preview {
    SearchShazamingView()
}
