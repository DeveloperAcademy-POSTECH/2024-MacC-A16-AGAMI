//
//  FirebaseAuthService.swift
//  AGAMI
//
//  Created by taehun on 10/18/24.
//

import Foundation
import CryptoKit
import FirebaseAuth

final class FirebaseAuthService {
    
    var currentNonce: String?

    static var currentUID: String? {
        if let uid = Auth.auth().currentUser?.uid {
            return uid
        }
        return nil
    }

    func generateNonce() {
        currentNonce = randomNonceString()
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
    
    func signOut(completion: @escaping (Result<Void, Error>) -> Void) {
           do {
               try Auth.auth().signOut()
               completion(.success(()))
           } catch let signOutError as NSError {
               completion(.failure(signOutError))
           }
       }
}
