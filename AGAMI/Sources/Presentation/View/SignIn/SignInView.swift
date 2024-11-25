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
            
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 0) {
                    Image(.signInLogo)
                        .resizable()
                        .frame(width: 73, height: 88)
                        .padding(EdgeInsets(top: 135, leading: 21, bottom: 0, trailing: 0))
                    
                    Spacer()
                }
                
                Text("소록")
                    .font(.sCoreDream(weight: .dream8, size: 36))
                    .foregroundStyle(Color(.sTitleText))
                    .padding(EdgeInsets(top: 45, leading: 24, bottom: 0, trailing: 0))
                
                Text(": 기억하고 싶은 모든 순간의 음악을 담다")
                    .font(.notoSansKR(weight: .medium500, size: 18))
                    .foregroundStyle(Color(.sSubHead))
                    .padding(EdgeInsets(top: 14, leading: 24, bottom: 0, trailing: 0))
                
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
                .padding(EdgeInsets(top: 0, leading: 16, bottom: 86, trailing: 16))
            }
            .ignoresSafeArea(edges: .bottom)
        }
    }
}

#Preview {
    SignInView()
}
