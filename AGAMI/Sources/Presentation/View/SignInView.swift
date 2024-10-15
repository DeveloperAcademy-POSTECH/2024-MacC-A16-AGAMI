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
        VStack {
            Spacer()

            SignInWithAppleButton(.continue) { request in
                request.requestedScopes = [.fullName, .email]
            } onCompletion: { result in
                switch result {
                case .success(let authorization):
                    viewModel.handleSuccessfulLogin(with: authorization)
                case .failure(let error):
                    viewModel.handleLoginError(with: error)
                }
            }
            .frame(height: 56)
            .padding(EdgeInsets(top: 0, leading: 20, bottom: 80, trailing: 20))
        }
    }
}
