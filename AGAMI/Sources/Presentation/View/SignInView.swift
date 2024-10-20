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
        ZStack(alignment: .top) {
            Color.primaryColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                Image(.plakeSignIn)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(EdgeInsets(top: 117, leading: 0, bottom: 0, trailing: 0))
                
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
                .padding(EdgeInsets(top: 0, leading: 16, bottom: 120, trailing: 16))
            }
        }
    }
}

#Preview {
    SignInView()
}
