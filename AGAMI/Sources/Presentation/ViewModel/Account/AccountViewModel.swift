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
    var isScucessDeleteAccount: Bool = false
    var isEditMode: Bool = false
    var isPresented: Bool = false
    
    var isShowingSignOutAlert: Bool = false
    var isDeletingAccount: Bool = false
    
    var userName: String = "가자미"
    
    var showPhotoPicker: Bool = false
    var selectedItem: PhotosPickerItem?
    var postImage: Image?
    
    func convertImage(item: PhotosPickerItem?) async {
        guard let item = item else { return }
        guard let data = try? await item.loadTransferable(type: Data.self) else { return }
        guard let uiImage = UIImage(data: data) else { return }
        self.postImage = Image(uiImage: uiImage)
    }
    
    func signOut() {
        firebaseAuthService.signOut { result in
            switch result {
            case .success:
                UserDefaults.standard.removeObject(forKey: "isSignedIn")
                dump("로그아웃 성공")
            case .failure(let error):
                dump("로그아웃 실패 \(error.localizedDescription)")
            }
        }
    }
    
    func deleteAccount() async {
        let success = await firebaseAuthService.deleteAccount()
        
        if success {
            isScucessDeleteAccount = true
            UserDefaults.standard.removeObject(forKey: "isSignedIn")
            dump("계정 삭제 성공")
        } else {
            dump("계정 삭제 실패")
        }
    }
    
    func koreaLangCheck(_ input: String) -> Bool {
        let pattern = "^[가-힣a-zA-Z\\s]*$"
        if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
            let range = NSRange(location: 0, length: input.utf16.count)
            if regex.firstMatch(in: input, options: [], range: range) != nil {
                return true
            }
        }
        return false
    }
}
