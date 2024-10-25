//
//  FirebaseService.swift
//  AGAMI
//
//  Created by taehun on 10/12/24.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage

final class FirebaseService {
    private let firestore = Firestore.firestore()
    private let firestorage = Storage.storage()

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
    
    func uploadImageToFirebase(userID: String, image: UIImage) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 1.0) else {
            throw NSError(domain: "ImageConversionError", code: -1, userInfo: [NSLocalizedDescriptionKey: "이미지를 데이터로 변환하는 데 실패했습니다."])
        }

        let uniqueID = UUID().uuidString

        let storageRef = firestorage.reference()
            .child("\(userID)/\(uniqueID)/image.jpg")

        _ = try await storageRef.putDataAsync(imageData, metadata: nil)

        let downloadURL = try await storageRef.downloadURL()

        return downloadURL.absoluteString
    }

    func deletePlaylist(userID: String, playlistID: String) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            firestore.collection("UserID")
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
}
