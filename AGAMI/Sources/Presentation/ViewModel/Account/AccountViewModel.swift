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

    // 계정 삭제에 대한 상태
    enum DeleteAccountProcess {
        case none
        case inProgress
        case finished
    }
    
    var deleteAccountProcess: DeleteAccountProcess = .none
    
    // 편집 모드 여부
    var isEditMode: Bool = false
    
    var isProfileImageDialogPresented: Bool = false
    var isShowingSignOutAlert: Bool = false
    var isDeletingAccount: Bool = false
    var isDefaultImage: Bool = false
    var isProfileImageChanged: Bool = false
    
    // 유저 프로필 이름
    var userName: String = "Plake"
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
            dump("UID를 가져오는 데 실패했습니다.")
            return
        }
        
        Task {
            try await deleteFirebaseData()
            
            let success = await firebaseAuthService.deleteAccount {
                self.deleteAccountProcess = .inProgress
            }
            
            if success {
                try await firebaseService.saveIsUserValued(userID: uid, isUserValued: false)
                deleteAccountProcess = .finished
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
        signOutUserID()
        isShowingSignOutAlert = false
    }
    
    func cancelDeleteAccountAlert() {
        isDeletingAccount = false
    }
    
    func showProfileImageDialog() {
        if isEditMode {
            isProfileImageDialogPresented = true
        }
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
                dump("유저 프로필 사진이 변경되었습니다.")
            }
            
            if isDefaultImage {
                await deletePhotoImageToFirebase()
                postImage = nil
                imageURL = ""
                isDefaultImage = false
                dump("유저 프로필 사진이 기본 사진으로 변경되었습니다. (사진 제거)")
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
