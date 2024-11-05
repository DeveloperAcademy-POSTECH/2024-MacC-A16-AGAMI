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
    
    var isScucessDeleteAccount: Bool = false
    
    var isEditMode: Bool = false
    var isPresented: Bool = false
    
    var isShowingSignOutAlert: Bool = false
    var isDeletingAccount: Bool = false

    var userName: String = "Plake"
    var isUserNameSaved: Bool = false
    
    var showPhotoPicker: Bool = false
    var selectedItem: PhotosPickerItem?
    var postImage: UIImage?
    var imageURL: String?
    
    func convertImage(item: PhotosPickerItem?) async {
        guard let item = item else { return }
        guard let data = try? await item.loadTransferable(type: Data.self) else { return }
        guard let uiImage = UIImage(data: data) else { return }
        self.postImage = uiImage
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
    
    func saveUserName(nickname: String) async {
        guard let uid = FirebaseAuthService.currentUID else {
            dump("UID를 가져오는 데 실패했습니다.")
            return
        }
        do {
            try await firebaseService.saveUserNickname(userID: uid, nickname: nickname)
            dump("닉네임을 저장하는데 성공했습니다.")
        } catch {
            dump("유저 닉네임을 저장하는데 실패했습니다.")
        }
    }
    
    func fetchUserInformation() async {
        guard let uid = FirebaseAuthService.currentUID else {
            dump("UID를 가져오는 데 실패했습니다.")
            return
        }
        
        do {
            let userInformation = try await firebaseService.fetchUserInformation(userID: uid)
            
            if let userName = userInformation["UserNickname"] as? String {
                self.userName = userName
            } else {
                dump("userName 값이 String 타입이 아니거나 nil입니다.")
            }
            
            if let imageURL = userInformation["UserImageURL"] as? String {
                self.imageURL = imageURL
            } else {
                dump("imageURL 값이 String 타입이 아니거나 nil입니다.")
            }
        } catch {
            dump("유저 정보를 불러오는데 실패했습니다.")
        }
    }
    
    func saveUserProfileImage(image: UIImage) async {
        guard let uid = FirebaseAuthService.currentUID else {
            dump("UID를 가져오는 데 실패했습니다.")
            return
        }
        
        do {
            try await firebaseService.uploadUserImageToFirebase(userID: uid, image: image)
            dump("유저 이미지를 저장하는데 성공했습니다.")
        } catch {
            dump("유저 이미지를 저장하는데 실패했습니다.")
        }
    }
}
