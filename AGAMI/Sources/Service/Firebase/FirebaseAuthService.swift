//
//  FirebaseAuthService.swift
//  AGAMI
//
//  Created by taehun on 10/18/24.
//

import Foundation
import CryptoKit
import FirebaseAuth
import AuthenticationServices
import FirebaseFirestore

final class FirebaseAuthService {
    
    private var authStateHandler: AuthStateDidChangeListenerHandle?
    
    var currentNonce: String?
    var user: User?
    
    static var currentUID: String? {
        if let uid = Auth.auth().currentUser?.uid {
            return uid
        }
        return nil
    }
    
    init() {
        registerAuthStateHandler()
    }
    
    static func checkUserValued() async throws {
        guard let uid = FirebaseAuthService.currentUID else {
            dump("UID를 가져오는 데 실패했습니다.")
            self.signOutUserID()
            return
        }
        
        let isUserValued = try await fetchIsUserValued(userID: uid)
        
        if isUserValued {
            dump("정상적인 사용자입니다.")
            return
        }
        
        self.signOutUserID()
    }
    
    static func signOutUserID() {
        signOut { result in
            switch result {
            case .success:
                UserDefaults.standard.removeObject(forKey: "isSignedIn")
                dump("로그아웃 성공")
            case .failure(let error):
                dump("로그아웃 실패 \(error.localizedDescription)")
            }
        }
    }
    
    func generateNonce() {
        currentNonce = randomNonceString()
    }
    
    func registerAuthStateHandler() {
        if authStateHandler == nil {
            authStateHandler = Auth.auth().addStateDidChangeListener { _, user in
                self.user = user
            }
        }
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0..<16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                
                if errorCode != errSecSuccess {
                    fatalError("Nonce 생성 실패. OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }
    
    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap { String(format: "%02x", $0) }.joined()
        return hashString
    }
    
    func signInWithFirebase(idTokenString: String, nonce: String, completion: @escaping (Result<String, Error>) -> Void) {
        let credential = OAuthProvider.credential(
            withProviderID: "apple.com",
            idToken: idTokenString,
            rawNonce: nonce
        )
        
        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            if let uid = authResult?.user.uid {
                completion(.success(uid))
            }
        }
    }
    
    static func signOut(completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(.success(()))
        } catch let signOutError as NSError {
            completion(.failure(signOutError))
        }
    }

    func deleteAccount(
        changeProcessInProgress: () async throws -> Void,
        changeProcessFinished: @escaping () -> Void
    ) async throws {
        guard let user = user else { return }
        guard let lastSignInDate = user.metadata.lastSignInDate else { return }
        let needsReAuth = !lastSignInDate.isWithinPast(minutes: 5)
        let needsTokenRevocation = user.providerData.contains { $0.providerID == "apple.com" }
        
        do {
            if needsReAuth || needsTokenRevocation {
                let signInWithApple = await SignInWithApple()
                let appleIDCredential = try await signInWithApple()
                
                try await changeProcessInProgress()

                guard let appleIDToken = appleIDCredential.identityToken else {
                    dump("Unable to fetch identity token.")
                    return
                }
                guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                    dump("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                    return
                }
                
                let nonce = randomNonceString()
                let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                          idToken: idTokenString,
                                                          rawNonce: nonce)
                if needsReAuth {
                    try await user.reauthenticate(with: credential)
                }
                if needsTokenRevocation {
                    guard let authorizationCode = appleIDCredential.authorizationCode else { return }
                    guard let authCodeString = String(data: authorizationCode, encoding: .utf8) else { return }
                    
                    try await Auth.auth().revokeToken(withAuthorizationCode: authCodeString)
                }
            }

            changeProcessFinished()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                dump("dispatch queue")
                Task {
                    do {
                        try await FirebaseService().deleteUserInformationDocument(userID: user.uid) {
                            dump("Firestore document deleted successfully.")
                        }
                        try await user.delete()
                        dump("Firebase user account deleted successfully.")
                    }
                }
            }
        } catch {
            dump("계정 삭제 중 오류 발생 in firebaseauthservice: \(error)")
            throw error
        }
    }
    
    static func fetchIsUserValued(userID: String) async throws -> Bool {
        let documentRef = Firestore
            .firestore()
            .collection("UserInformation")
            .document(userID)
        
        do {
            let documentSnapshot = try await documentRef.getDocument()
            
            guard documentSnapshot.exists else {
                dump("UserInformation 문서가 존재하지 않습니다.")
                return false
            }
            
            guard let isUserValued = documentSnapshot.get("isUserValued") as? Bool else {
                dump("isUserValued 필드를 찾을 수 없습니다.")
                return false
            }
            
            dump("isUserValued 받아옴: \(isUserValued)")
            return isUserValued
        } catch {
            dump("Error fetching isUserValued: \(error.localizedDescription)")
            return false
        }
    }
}

final class SignInWithApple: NSObject, ASAuthorizationControllerDelegate {
  private var continuation: CheckedContinuation<ASAuthorizationAppleIDCredential, Error>?

  func callAsFunction() async throws -> ASAuthorizationAppleIDCredential {
    return try await withCheckedThrowingContinuation { continuation in
      self.continuation = continuation
      let appleIDProvider = ASAuthorizationAppleIDProvider()
      let request = appleIDProvider.createRequest()
      request.requestedScopes = [.fullName, .email]

      let authorizationController = ASAuthorizationController(authorizationRequests: [request])
      authorizationController.delegate = self
      authorizationController.performRequests()
    }
  }

  func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
    if case let appleIDCredential as ASAuthorizationAppleIDCredential = authorization.credential {
      continuation?.resume(returning: appleIDCredential)
    }
  }

  func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    continuation?.resume(throwing: error)
  }
}
