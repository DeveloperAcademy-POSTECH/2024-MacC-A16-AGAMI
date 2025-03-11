//
//  SignInView.swift
//  AGAMI
//
//  Created by 박현수 on 10/15/24.
//

import SwiftUI
import AuthenticationServices

struct SignInView: View {
    @State private var viewModel: SignInViewModel = SignInViewModel()
    
    var body: some View {
        ZStack {
            Color(.sMain)
                .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                Image(.signinLogo)

                Text("기억하고 싶은 모든\n순간의 음악을 담다")
                    .font(.notoSansKR(weight: .regular400, size: 18))
                    .foregroundStyle(Color(.sSubHead))

                Spacer()
            }

            VStack {
                Spacer()

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
                .frame(height: 54)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 32, trailing: 20))
                .ignoresSafeArea(edges: .bottom)
            }
        }
    }
}

#Preview {
    SignInView()
}
