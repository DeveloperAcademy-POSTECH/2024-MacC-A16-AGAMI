//
//  SignInViewModel.swift
//  AGAMI
//
//  Created by 박현수 on 10/15/24.
//

import Foundation
import AuthenticationServices

@Observable
final class SignInViewModel {
    func handleSuccessfulLogin(with authorization: ASAuthorization) {
        if let userCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            dump(userCredential.user)
            dump(userCredential.email)
            dump(userCredential.fullName)
            if userCredential.authorizedScopes.contains(.fullName) {
                dump(userCredential.fullName?.givenName ?? "No given name")
            }

            if userCredential.authorizedScopes.contains(.email) {
                dump(userCredential.email ?? "No email")
            }
        }
        UserDefaults.standard.set(true, forKey: "isSignedIn")
    }

    func handleLoginError(with error: Error) {
        dump("Could not authenticate: \(error.localizedDescription)")
    }
}
