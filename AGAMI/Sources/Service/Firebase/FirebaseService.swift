//
//  FirebaseService.swift
//  AGAMI
//
//  Created by taehun on 10/12/24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage

final class FirebaseService {
    private let firestore = Firestore.firestore()
    private let firestorage = Storage.storage()
    private let batch = Firestore.firestore().batch()
    
    func savePlaylistToFirebase(userID: String, playlist: FirestorePlaylistModel) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            do {
                try firestore.collection("UserID")
                    .document(userID)
                    .collection("PlaylistID")
                    .document(playlist.playlistID)
                    .setData(from: playlist) { error in
                        if let error = error {
                            continuation.resume(throwing: error)
                        } else {
                            dump("Playlist successfully saved to Firestore!")
                            continuation.resume(returning: ())
                        }
                    }
            } catch let error {
                continuation.resume(throwing: error)
            }
        }
    }

    func fetchPlaylistsByUserID(userID: String) async throws -> [FirestorePlaylistModel] {
        let snapshot = try await firestore.collection("UserID")
            .document(userID)
            .collection("PlaylistID")
            .getDocuments()

        var playlists: [FirestorePlaylistModel] = []

        for document in snapshot.documents {
            do {
                let playlist = try document.data(as: FirestorePlaylistModel.self)
                playlists.append(playlist)
            } catch {
                dump("Error decoding playlist: \(error.localizedDescription)")
            }
        }

        return playlists
    }

    func fetchPlaylist(userID: String, playlistID: String) async -> FirestorePlaylistModel? {
        let documentRef = firestore.collection("UserID")
            .document(userID)
            .collection("PlaylistID")
            .document(playlistID)

        do {
            let playlist = try await documentRef.getDocument(as: FirestorePlaylistModel.self)
            return playlist
        } catch {
            dump("Error decoding playlist: \(error.localizedDescription)")
            return nil
        }
    }
    
    func uploadImageToFirebase(userID: String, image: UIImage) async throws -> String {
        guard let resizedImage = resizeImage(image: image, targetSize: CGSize(width: 1024, height: 1024)),
              let imageData = resizedImage.jpegData(compressionQuality: 0.7) else {
            throw NSError(domain: "ImageConversionError", code: -1, userInfo: [NSLocalizedDescriptionKey: "이미지를 데이터로 변환하는 데 실패했습니다."])
        }

        let uniqueID = UUID().uuidString
        let storageRef = Storage.storage().reference()
            .child("\(userID)/\(uniqueID)/image.jpg")
        
        do {
            _ = try await storageRef.putDataAsync(imageData, metadata: nil)
            
            let downloadURL = try await storageRef.downloadURL()
            return downloadURL.absoluteString
        } catch {
            print("Failed to upload image to Firebase: \(error)")
            throw error
        }
    }

    // 이미지 크기 조정 함수
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
        let size = image.size
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        let newSize = widthRatio < heightRatio
            ? CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
            : CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }

    func deletePlaylist(userID: String, playlistID: String) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            firestore
                .collection("UserID")
                .document(userID)
                .collection("PlaylistID")
                .document(playlistID)
                .delete { error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        dump("Playlist successfully deleted from Firestore!")
                        continuation.resume(returning: ())
                    }
                }
        }
    }

    func deleteImageInFirebase(userID: String, photoURL: String) async throws {
        let imageIDFolder = firestorage
                                .reference()
                                .child("\(userID)/\(photoURL)")
        
        try await deleteFilesRecursively(in: imageIDFolder)
        dump("Image files in storage successfully deleted")
    }
    
    func deleteAllPlaylists(userID: String) async throws {
        let playlists = try await firestore
                                    .collection("UserID")
                                    .document(userID)
                                    .collection("PlaylistID")
                                    .getDocuments()
                                    .documents
        
        for playlist in playlists {
            batch.deleteDocument(playlist.reference)
        }
        
        try await batch.commit()
        dump("All playlists successfully deleted")
        
        try await firestore.collection("UserID").document(userID).delete()
        dump("document(\(userID)) successfully deleted")
    }
    
    func deleteAllPhotoInStorage(userID: String) async throws {
        let userIDFolder = firestorage
                                .reference()
                                .child(userID)
        
        try await deleteFilesRecursively(in: userIDFolder)
        dump("All files in storage successfully deleted")
    }
    
    private func deleteFilesRecursively(in folder: StorageReference) async throws {
        let items = try await folder.listAll()
        
        for item in items.items {
            try await item.delete()
        }
        
        for prefix in items.prefixes {
            try await deleteFilesRecursively(in: prefix)
        }
    }
    
    func saveUserNickname(userID: String, nickname: String) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            firestore
                .collection("UserInformation")
                .document(userID)
                .setData(["UserNickname": nickname], merge: true) { error in
                    
                if let error = error {
                    dump("Failed to save UserNickname: \(error.localizedDescription)")
                    continuation.resume(throwing: error)
                } else {
                    dump("UserNickname successfully saved to Firestore!")
                    continuation.resume(returning: ())
                }
            }
        }
    }
    
    func uploadUserImageToFirebase(userID: String, image: UIImage) async throws {
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            throw NSError(domain: "ImageConversionError", code: -1, userInfo: [NSLocalizedDescriptionKey: "이미지를 데이터로 변환하는 데 실패했습니다."])
        }

        let storageRef = firestorage.reference()
            .child("\(userID)/UserImage/image.jpg")

        _ = try await storageRef.putDataAsync(imageData, metadata: nil)
        
        let downloadURL = try await storageRef.downloadURL()
        let downloadURLString = downloadURL.absoluteString

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            firestore
                .collection("UserInformation")
                .document(userID)
                .setData(["UserImageURL": downloadURLString], merge: true) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    dump("UserImageURL successfully saved to Firestore!")
                    continuation.resume(returning: ())
                }
            }
        }
    }
    
    func deleteUserImageInFirebase(userID: String) async throws {
        let imageIDFolder = firestorage
                                .reference()
                                .child("\(userID)/UserImage")
        
        try await deleteFilesRecursively(in: imageIDFolder)
        dump("Image files in storage successfully deleted")
    }
    
    func fetchUserInformation(userID: String) async throws -> [String: Any] {
        let documentSnapshot = try await firestore
                                            .collection("UserInformation")
                                            .document(userID)
                                            .getDocument()
        
        guard let data = documentSnapshot.data() else {
            throw NSError(domain: "FirestoreError", code: -1, userInfo: [NSLocalizedDescriptionKey: "사용자 데이터를 찾을 수 없습니다."])
        }
        
        var result: [String: Any] = [:]
        if let userNickname = data["UserNickname"] {
            result["UserNickname"] = userNickname
        }
        if let userImageURL = data["UserImageURL"] {
            result["UserImageURL"] = userImageURL
        }
        return result
    }
    
    func saveIsUserValued(userID: String, isUserValued: Bool) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            firestore
                .collection("UserInformation")
                .document(userID)
                .setData(["isUserValued": isUserValued], merge: true) { error in
                if let error = error {
                    dump("Failed to save isUserValued: \(error.localizedDescription)")
                    continuation.resume(throwing: error)
                } else {
                    dump("isUserValued successfully saved to Firestore!")
                    continuation.resume(returning: ())
                }
            }
        }
    }
}
