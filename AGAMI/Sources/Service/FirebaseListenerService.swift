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
    
    func startListening(userID: String) {
        playlistListener = firestore
            .collection("UserID")
            .document(userID)
            .collection("PlaylistID")
            .addSnapshotListener { snapshot, error in
                guard let snapshot = snapshot else {
                    print("Error fetching snapshot: \(error!)")
                    return
                }

                snapshot.documentChanges.forEach { diff in
                    if diff.type == .added {
                        dump("New document: \(diff.document.data())")
                    }
                    if diff.type == .modified {
                        dump("Modified document: \(diff.document.data())")
                    }
                    if diff.type == .removed {
                        dump("Removed document: \(diff.document.data())")
                    }
                }
            }
    }

    func stopListening() {
        playlistListener?.remove()
        playlistListener = nil
    }

    func listener(userID: String) {
        firestore
            .collection("UserID")
            .document(userID)
            .collection("PlaylistID")
            .addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot else {
                dump("Error fetching snapshot: \(error!)")
                return
            }

            snapshot.documentChanges.forEach { diff in
                if (diff.type == .added) {
                    dump("New user: \(diff.document.data())")
                }
                if (diff.type == .modified) {
                    dump("Modified user: \(diff.document.data())")
                }
                if (diff.type == .removed) {
                    dump("Removed user: \(diff.document.data())")
                }
            }
        }
    }
}
