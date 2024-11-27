//
//  AccountViewModel.swift
//  AGAMI
//
//  Created by yegang on 11/3/24.
//

import SwiftUI
import PhotosUI

@Observable
final class AccountViewModel {
    private let firebaseAuthService: FirebaseAuthService = FirebaseAuthService()
    private let firebaseService: FirebaseService = FirebaseService()
    
    var termsOfServiceURL: URL? {
        URL(string: "https://posacademy.notion.site/Plake-1302b843d5af81969d94daddfac63fde?pvs=4")
    }
    var isShowingSignOutAlert: Bool = false
    var isShowingDeleteAccountAlert: Bool = false
    // 계정 삭제에 대한 상태
    enum DeleteAccountProcess {
        case none
        case inProgress
        case finished
    }
    
    var deleteAccountProcess: DeleteAccountProcess = .none
}
// MARK: - 로그아웃, 회원 탈퇴
extension AccountViewModel {
    func cancelSignOutAlert() {
        isShowingSignOutAlert = false
    }
    
    func confirmSignOut() {
        signOutUserID()
        isShowingSignOutAlert = false
    }
    
    func signOutUserID() {
        FirebaseAuthService.signOut { result in
            switch result {
            case .success:
                UserDefaults.standard.removeObject(forKey: "isSignedIn")
                dump("로그아웃 성공")
            case .failure(let error):
                dump("로그아웃 실패 \(error.localizedDescription)")
            }
        }
    }
    
    func cancelDeleteAccountAlert() {
        isShowingDeleteAccountAlert = false
    }
    
    func deleteFirebaseData() async throws {
        guard let uid = FirebaseAuthService.currentUID else {
            dump("UID를 가져오는 데 실패했습니다.")
            return
        }
        
        try await firebaseService.deleteAllPlaylists(userID: uid)
        try await firebaseService.deleteAllPhotoInStorage(userID: uid)
    }
    
    func deleteAccount() {
        Task {
            do {
                try firebaseAuthService.updateAuthProcessState()
                let appleIDCedential = try await firebaseAuthService.appleAuthentication()
                
                self.deleteAccountProcess = .inProgress
                try await self.deleteFirebaseData()
                try await firebaseAuthService.handleAppleIDAuthentication(appleIDCredential: appleIDCedential)
                
                self.deleteAccountProcess = .finished
                try await firebaseAuthService.deleteUserInfoWithDelay()
            } catch {
                dump("계정 삭제 중 오류 발생 in accountviewmdoel: \(error.localizedDescription)")
                deleteAccountProcess = .none
            }
        }
    }
}
