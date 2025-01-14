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
    var authProcessState: AuthProcessState = .none
    
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
    
    func updateAuthProcessState() throws {
        guard let user = user else {
            throw AuthServiceError.userNotFound
        }
        guard let lastSignInDate = user.metadata.lastSignInDate else {
            throw AuthServiceError.lastSignInDateNotFound
        }
        
        let needsReAuth = !lastSignInDate.isWithinPast(minutes: 5)
        let needsTokenRevocation = user.providerData.contains { $0.providerID == "apple.com" }
        
        if needsReAuth && needsTokenRevocation {
            authProcessState = .needsFullAuthenticationProcess
        } else if needsReAuth {
            authProcessState = .needsReAuth
        } else if needsTokenRevocation {
            authProcessState = .needsTokenRevocation
        } else {
            authProcessState = .none
        }
    }
    
    func appleAuthentication() async throws -> ASAuthorizationAppleIDCredential {
        if authProcessState == .none {
            throw AuthServiceError.userNotFound
        }

        let signInWithApple = await SignInWithApple()
        let appleIDCredential = try await signInWithApple()
        return appleIDCredential
    }
    
    func handleAppleIDAuthentication(appleIDCredential: ASAuthorizationAppleIDCredential) async throws {
        guard let user = user else {
            throw AuthServiceError.userNotFound
        }

        guard let appleIDToken = appleIDCredential.identityToken else {
            throw AuthServiceError.lastSignInDateNotFound
        }

        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            throw AuthServiceError.lastSignInDateNotFound
        }

        let nonce = randomNonceString()
        let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                  idToken: idTokenString,
                                                  rawNonce: nonce)

        if authProcessState == .needsReAuth || authProcessState == .needsFullAuthenticationProcess {
            try await user.reauthenticate(with: credential)
        }

        if authProcessState == .needsTokenRevocation || authProcessState == .needsFullAuthenticationProcess {
            guard let authorizationCode = appleIDCredential.authorizationCode else {
                throw AuthServiceError.lastSignInDateNotFound
            }
            guard let authCodeString = String(data: authorizationCode, encoding: .utf8) else {
                throw AuthServiceError.lastSignInDateNotFound
            }
            
            try await Auth.auth().revokeToken(withAuthorizationCode: authCodeString)
        }

        authProcessState = .none
    }
    
    func deleteUserInfoWithDelay() async throws {
        guard let user = user else {
            throw AuthServiceError.userNotFound
        }
        Task {
            try await Task.sleep(for: .seconds(2))
            do {
                try await FirebaseService().deleteUserInformationDocument(userID: user.uid) {
                    dump("Firestore document deleted successfully.")
                }
                try await user.delete()
                dump("Firebase user account deleted successfully.")
            }
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
    
    enum AuthProcessState {
        case needsFullAuthenticationProcess
        case needsReAuth
        case needsTokenRevocation
        case none
    }
    
    enum AuthServiceError: Error {
        case userNotFound
        case lastSignInDateNotFound
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
