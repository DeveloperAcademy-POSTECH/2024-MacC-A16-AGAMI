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
    private let storage = Storage.storage()
    @State var image: UIImage?
    @State var imageUrl: String?
    
    init() {
            print("FirebaseService initialized")
        }
    
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
    
    func saveImageToFirebaseStorage(image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        
        let storageRef = storage.reference().child("images/\(UUID().uuidString).jpg")
        
        storageRef.putData(imageData, metadata: nil) { (metadata, error) in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
                return
            }
            
            storageRef.downloadURL { (url, error) in
                if let error = error {
                    print("Error getting download URL: \(error.localizedDescription)")
                    return
                }
                
                if let downloadURL = url?.absoluteString {
                    DispatchQueue.main.async {
                        self.imageUrl = downloadURL
                    }
                    self.saveImageUrlToFirestore(imageUrl: downloadURL)
                }
            }
        }
    }
    
    func saveImageUrlToFirestore(imageUrl: String) {
        firestore.collection("images").addDocument(data: ["imageUrl": imageUrl]) { error in
            if let error = error {
                print("Error saving image URL to Firestore: \(error)")
            } else {
                print("Image URL successfully saved to Firestore")
            }
        }
    }
}
