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
    
    var termsOfServiceURL: URL {
        if let url = URL(string: "https://posacademy.notion.site/Plake-1302b843d5af81969d94daddfac63fde?pvs=4") {
            return url
        } else {
            dump("잘못된 URL입니다.")
            return(URL(string: "https://www.google.co.kr/")!)
        }
    }
    var isShowingSignOutAlert: Bool = false
    var isShowingDeleteAccountAlert: Bool = false
    // 창 안 닫히게 하는건데 pr 날리고 한 번에 코디네이터에서 수정해도 괜찮을듯
    var isAbleClosed: Bool = false
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
        guard let uid = FirebaseAuthService.currentUID else {
            dump("viewModel UID를 가져오는 데 실패했습니다.")
            return
        }
        
        Task {
            do {
                try await deleteFirebaseData()
                try await firebaseService.deleteUserInformationDocument(userID: uid) {
                    self.deleteAccountProcess = .finished
                }
                await firebaseAuthService.deleteAccount {
                    self.deleteAccountProcess = .inProgress
                }
            } catch {
                dump("계정 삭제 중 오류 발생: \(error.localizedDescription)")
            }
        }
    }
}
