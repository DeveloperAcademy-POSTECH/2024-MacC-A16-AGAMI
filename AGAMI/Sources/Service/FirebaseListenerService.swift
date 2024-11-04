//
//  FirebaseListenerService.swift
//  AGAMI
//
//  Created by taehun on 11/1/24.
//

import Foundation
import FirebaseFirestore

final class FirebaseListenerService {
    private let firestore = Firestore.firestore()
    private var playlistListener: ListenerRegistration?

    func startListeningPlaylist(userID: String, onChange: @escaping ([DocumentChange]) -> Void) {
        dump("Start listening playlist")
        playlistListener = firestore
            .collection("UserID")
            .document(userID)
            .collection("PlaylistID")
            .addSnapshotListener { snapshot, error in
                guard let snapshot = snapshot else {
                    dump("Error fetching snapshot: \(error!)")
                    return
                }
                onChange(snapshot.documentChanges)
            }
    }

    func stopListeningPlaylist() {
        playlistListener?.remove()
        playlistListener = nil
    }
}
