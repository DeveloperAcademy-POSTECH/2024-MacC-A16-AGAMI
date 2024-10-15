//
//  FirebaseService.swift
//  AGAMI
//
//  Created by taehun on 10/12/24.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift
import FirebaseStorage

final class FirebaseService: ObservableObject {
    private let firestore = Firestore.firestore()
    private let firestorage = Storage.storage()

    func savePlaylistToFirebase(userID: String, playlist: PlaylistModel) {
        do {
            try firestore.collection("UserID")
                .document(userID)
                .collection("PlaylistID")
                .document(playlist.playlistID.uuidString)
                .setData(from: playlist) { error in
                    if let error = error {
                        print("Error saving playlist to Firestore: \(error.localizedDescription)")
                    } else {
                        print("Playlist successfully saved to Firestore!")
                    }
                }
        } catch let error {
            print("Error serializing playlist: \(error.localizedDescription)")
        }
    }

    func fetchPlaylistsByUserID(userID: String, completion: @escaping (Result<[PlaylistModel], Error>) -> Void) {
        firestore.collection("UserID")
            .document(userID)
            .collection("PlaylistID")
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                var playlists: [PlaylistModel] = []
                
                querySnapshot?.documents.forEach { document in
                    do {
                        let playlist = try document.data(as: PlaylistModel.self)
                        playlists.append(playlist)
                    } catch {
                        print("Error decoding playlist: \(error.localizedDescription)")
                    }
                }
                
                completion(.success(playlists))
            }
    }

    func uploadImageToFirebase(userID: String, playlistID: String, image: UIImage, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 1.0) else {
            completion(.failure(NSError(domain: "ImageConversionError", code: -1, userInfo: [NSLocalizedDescriptionKey: "이미지를 데이터로 변환하는 데 실패했습니다."])))
            return
        }
        
        let storageRef = firestorage.reference()
            .child("\(userID)/\(playlistID)/image.jpg")
        
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            storageRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                if let downloadURL = url?.absoluteString {
                    let playlistRef = self.firestore.collection("UserID")
                        .document(userID)
                        .collection("PlaylistID")
                        .document(playlistID)
                    
                    playlistRef.updateData([
                        "photoURL": downloadURL
                    ]) { error in
                        if let error = error {
                            completion(.failure(error))
                        } else {
                            print("Firestore에 사진 URL이 성공적으로 업데이트되었습니다!")
                            completion(.success(()))
                        }
                    }
                } else {
                    completion(.failure(NSError(domain: "URLError", code: -1, userInfo: [NSLocalizedDescriptionKey: "다운로드 URL을 가져오는 데 실패했습니다."])))
                }
            }
        }
    }
}
