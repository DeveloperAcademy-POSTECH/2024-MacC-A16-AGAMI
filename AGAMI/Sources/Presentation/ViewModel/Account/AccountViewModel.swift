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
    
    // 회원탈퇴 여부
    var isScucessDeleteAccount: Bool = false
    
    // 편집 모드 여부
    var isEditMode: Bool = false
    
    var isProfileImageDialogPresented: Bool = false
    var isShowingSignOutAlert: Bool = false
    var isDeletingAccount: Bool = false
    var isDefaultImage: Bool = false
    var isProfileImageChanged: Bool = false
    
    // 유저 프로필 이름
    var userName: String = "닉네임"
    var editingUserName = ""
    
    // 유저 프로필 이미지
    var isShowPhotoPicker: Bool = false
    var selectedItem: PhotosPickerItem?
    var postImage: UIImage?
    var imageURL: String = ""
    
    func convertImage(item: PhotosPickerItem?) {
        Task {
            guard let item = item else { return }
            guard let data = try? await item.loadTransferable(type: Data.self) else { return }
            guard let uiImage = UIImage(data: data) else { return }
            self.postImage = uiImage
            isProfileImageChanged = true
        }
    }
    
    func fetchUserInformation() {
        Task {
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
    }
}

/// 로그인 로그아웃
extension AccountViewModel {
    
    func logoutButtonTapped() {
        isShowingSignOutAlert = true
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
    
    func deleteFirebaseData() async throws {
        guard let uid = FirebaseAuthService.currentUID else {
            dump("UID를 가져오는 데 실패했습니다.")
            return
        }
        
        try await firebaseService.deleteAllPlaylists(userID: uid)
        try await firebaseService.deleteAllPhotoInStorage(userID: uid)
    }
    
    func deleteAccount() async throws {
        guard let uid = FirebaseAuthService.currentUID else {
            dump("UID를 가져오는 데 실패했습니다.")
            return
        }
        
        let success = await firebaseAuthService.deleteAccount()
    func deleteAccount() {
        Task {
            let success = await firebaseAuthService.deleteAccount()
            
            if success {
                isScucessDeleteAccount = true
                dump("계정 삭제 성공")
            } else {
                dump("계정 삭제 실패")
            }
        }
    }
}

/// 프로필 편집
extension AccountViewModel {
    func changeDefaultImage() {
        postImage = nil
        imageURL = ""
        
        isDefaultImage = true
    }
    
    func albumButtonTapped() {
        isShowPhotoPicker.toggle()
    }
    
    func startEditButtonTapped() {
        editingUserName = userName
        
        isEditMode = true
    }
    
    func cancelSignOutAlert() {
        isShowingSignOutAlert = false
    }
    
    func confirmSignOut() {
        signOut()
        isShowingSignOutAlert = false
    }
    
    func cancelDeleteAccountAlert() {
        isDeletingAccount = false
    }
    
    func showProfileImageDialog() {
        isProfileImageDialogPresented = true
    }
    
    func deleteAccountButtonTapped() {
        isDeletingAccount = true
    }
    
    func endEditButtonTapped() {
        Task {
            if userName != editingUserName {
                await saveUserName(nickname: userName)
            }
            
            if isProfileImageChanged, let image = postImage {
                await savePhotoImageToFirebase(image: image)
                isProfileImageChanged = false
                dump("해냈냐?")
            }
            
            if isDefaultImage {
                await deletePhotoImageToFirebase()
                postImage = nil
                imageURL = ""
                isDefaultImage = false
                dump("제거했냐")
            }

            fetchUserInformation()
        }
        
        isEditMode = false
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
    
    func savePhotoImageToFirebase(image: UIImage) async {
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
    
    func deletePhotoImageToFirebase() async {
        guard let uid = FirebaseAuthService.currentUID else {
            dump("UID를 가져오는 데 실패했습니다.")
            return
        }
        
        do {
            try await firebaseService.deleteUserImageInFirebase(userID: uid)
            dump("유저 이미지를 삭제하는데 성공했습니다.")
        } catch {
            dump("유저 이미지를 삭제하는데 실패했습니다.")
        }
    }
}
