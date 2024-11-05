////
////  FirebaseListenerService.swift
////  AGAMI
////
////  Created by taehun on 11/1/24.
////
//
//import Foundation
//import FirebaseFirestore
//
//final class FirebaseListenerService {
//    private let firestore = Firestore.firestore()
//    private var playlistListener: ListenerRegistration?
//    private var snapshots: [String: DocumentSnapshot] = [:]
//
//    func fetchInitialPlaylistSnapshot(userID: String) async throws -> [DocumentSnapshot] {
//        try await withCheckedThrowingContinuation { continuation in
//            let collectionRef = firestore
//                .collection("UserID")
//                .document(userID)
//                .collection("PlaylistID")
//
//            collectionRef.getDocuments { snapshot, error in
//                if let snapshot = snapshot {
//                    self.snapshots = snapshot.documents.reduce(into: [:]) { result, document in
//                        result[document.documentID] = document
//                    }
//                    dump("Fetched initial playlist snapshot")
//                    continuation.resume(returning: snapshot.documents)
//                } else if let error = error {
//                    continuation.resume(throwing: error)
//                }
//            }
//        }
//    }
//
//    func startListeningPlaylist(userID: String, onChange: @escaping ([DocumentChange]) -> Void) {
//        dump("Start listening playlist")
//
//        let collectionRef = firestore
//            .collection("UserID")
//            .document(userID)
//            .collection("PlaylistID")
//
//        playlistListener = collectionRef.addSnapshotListener { [weak self] snapshot, error in
//            guard let self = self, let snapshot = snapshot else {
//                dump("Error fetching snapshot: \(error!)")
//                return
//            }
//
//            let filteredChanges = snapshot.documentChanges.filter { change in
//                switch change.type {
//                case .added:
//                    let isNewDocument = self.snapshots[change.document.documentID] == nil
//                    if isNewDocument {
//                        self.snapshots[change.document.documentID] = change.document
//                    }
//                    return isNewDocument
//                case .modified:
//                    if let oldDocument = self.snapshots[change.document.documentID],
//                       let oldData = oldDocument.data() {
//                        
//                        let newData = change.document.data()
//                        
//                        if self.dictionariesAreEqual(oldData, newData) {
//                            self.snapshots[change.document.documentID] = change.document
//                            return true
//                        }
//                    }
//                    return false
//                case .removed:
//                    let wasExistingDocument = self.snapshots.removeValue(forKey: change.document.documentID) != nil
//                    return wasExistingDocument
//                }
//            }
//
//            if !filteredChanges.isEmpty {
//                onChange(filteredChanges)
//            }
//        }
//    }
//
//
//    func dictionariesAreEqual(_ dict1: [String: Any], _ dict2: [String: Any]) -> Bool {
//        return NSDictionary(dictionary: dict1).isEqual(to: dict2)
//    }
//
//    func stopListeningPlaylist() {
//        playlistListener?.remove()
//        playlistListener = nil
//    }
//}
