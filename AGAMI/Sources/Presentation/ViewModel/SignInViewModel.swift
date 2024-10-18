//
//  SignInViewModel.swift
//  AGAMI
//
//  Created by 박현수 on 10/15/24.
//

import Foundation
import AuthenticationServices

@Observable
class SignInViewModel {
        
    private let firebaseAuthService = FirebaseAuthService()

    func signInRequest(request: ASAuthorizationAppleIDRequest) {
        firebaseAuthService.generateNonce()
        request.requestedScopes = [.fullName, .email]
        if let nonce = firebaseAuthService.currentNonce {
            request.nonce = firebaseAuthService.sha256(nonce)
        }
    }
    
    
    func handleSuccessfulLogin(with authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let idToken = appleIDCredential.identityToken
            
            guard let nonce = firebaseAuthService.currentNonce else {
                dump("Nonce가 존재하지 않습니다.")
                return
            }
            
            guard let idTokenString = idToken.flatMap({ String(data: $0, encoding: .utf8) }) else {
                dump("ID 토큰을 가져오는 데 실패했습니다.")
                return
            }
            
            firebaseAuthService.signInWithFirebase(idTokenString: idTokenString, nonce: nonce) { result in
                switch result {
                case .success(let uid):
                    dump("Firebase에 사용자 로그인 완료: \(uid)")
                    UserDefaults.standard.set(true, forKey: "isSignedIn")
                case .failure(let error):
                    dump("Firebase 로그인 에러: \(error.localizedDescription)")
                    self.handleLoginError(with: error)
                }
            }

            if appleIDCredential.authorizedScopes.contains(.fullName) {
                dump(appleIDCredential.fullName?.givenName ?? "이름 없음")
            }
            
            if appleIDCredential.authorizedScopes.contains(.email) {
                dump(appleIDCredential.email ?? "이메일 없음")
            }
        }
    }
    
    func handleLoginError(with error: Error) {
        dump("인증 실패: \(error.localizedDescription)")
    }
}
