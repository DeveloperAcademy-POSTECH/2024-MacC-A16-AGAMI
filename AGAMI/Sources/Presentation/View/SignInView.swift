//
//  SignInView.swift
//  AGAMI
//
//  Created by 박현수 on 10/15/24.
//

import SwiftUI
import AuthenticationServices
import FirebaseAuth
import CryptoKit

struct SignInView: View {
    @State private var viewModel: SignInViewModel = SignInViewModel()
    
    var body: some View {
        ZStack {
            Image(.signInBackground)
                .resizable()
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                Spacer()
                
                Image(.signInLogo)
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 24, trailing: 20))
                
                Text("순간을 놓치지 않는 즐거움,\n나만의 플라키브 생성하기")
                    .font(.pretendard(weight: .semiBold600, size: 18))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .foregroundStyle(Color(.pBlack))
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 234, trailing: 20))
                
                SignInWithAppleButton(.continue) { request in
                    viewModel.signInRequest(request: request)
                } onCompletion: { result in
                    switch result {
                    case .success(let authorization):
                        viewModel.handleSuccessfulLogin(with: authorization)
                    case .failure(let error):
                        viewModel.handleLoginError(with: error)
                    }
                }
                .frame(height: 56)
                .padding(EdgeInsets(top: 0, leading: 16, bottom: 80, trailing: 16))
            }
        }
    }
}
