//
//  FirebaseService.swift
//  AGAMI
//
//  Created by taehun on 10/12/24.
//
import Firebase
import FirebaseFirestore

final class FirebaseService: ObservableObject {
    private let firestore = Firestore.firestore()
    
    func savePlaylistToFirebase(_ playlist: PlaylistModel) {
        let geoPoint = GeoPoint(latitude: playlist.latitude, longitude: playlist.longitude)
        let playlistData: [String: Any] = [
            "playlistName": playlist.playlistName,
            "authorID": playlist.authorID.uuidString,
            "mainPhotoURL": playlist.mainPhotoURL,
            "photoURL": playlist.photoURL,
            "location": geoPoint,
            "musicID": playlist.musicID,
            "generationTime": Timestamp(date: playlist.generationTime)
        ]
        
        firestore.collection("PlaylistData")
            .document(playlist.id.uuidString)
            .setData(playlistData) { error in
                if let error = error {
                    print("Error saving playlist to Firestore: \(error.localizedDescription)")
                } else {
                    print("Playlist successfully saved to Firestore!")
                }
            }
    }
    
    func fetchPlaylistsIDByAuthorID(authorID: String, completion: @escaping (Result<[String], Error>) -> Void) {
        firestore.collection("PlaylistData")
            .whereField("authorID", isEqualTo: authorID)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                var playlistIDs: [String] = []
                
                for document in querySnapshot?.documents ?? [] {
                    playlistIDs.append(document.documentID)
                }
                completion(.success(playlistIDs))
            }
    }
    
    func fetchPlaylistByID(playlistID: String, completion: @escaping (Result<PlaylistModel, Error>) -> Void) {
        firestore.collection("PlaylistData")
            .document(playlistID)
            .getDocument { (document, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                if let document = document, document.exists {
                    let data = document.data()
                    
                    let id = UUID(uuidString: document.documentID) ?? UUID()
                    let playlistName = data?["playlistName"] as? String ?? ""
                    let authorIDString = data?["authorID"] as? String ?? ""
                    let authorID = UUID(uuidString: authorIDString) ?? UUID()
                    let mainPhotoURL = data?["mainPhotoURL"] as? String ?? ""
                    let photoURL = data?["photoURL"] as? [String] ?? []
                    let latitude = (data?["location"] as? GeoPoint)?.latitude ?? 0.0
                    let longitude = (data?["location"] as? GeoPoint)?.longitude ?? 0.0
                    let musicID = data?["musicID"] as? [String] ?? []
                    let generationTime = (data?["generationTime"] as? Timestamp)?.dateValue() ?? Date()
                    
                    let playlist = PlaylistModel(
                        id: id,
                        playlistName: playlistName,
                        authorID: authorID,
                        mainPhotoURL: mainPhotoURL,
                        photoURL: photoURL,
                        latitude: latitude,
                        longitude: longitude,
                        musicID: musicID,
                        generationTime: generationTime
                    )
                    
                    completion(.success(playlist))
                    return
                }
                print("Playlist does not exist.")
                completion(.failure(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Playlist does not exist"])))
            }
    }
}
