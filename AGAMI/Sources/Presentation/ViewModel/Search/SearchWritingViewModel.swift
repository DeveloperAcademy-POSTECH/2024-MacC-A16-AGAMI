//
//  SearchWritingViewModel.swift
//  AGAMI
//
//  Created by Seoyeon Choi on 10/16/24.
//

import SwiftUI
import CoreLocation
import PhotosUI

@Observable
final class SearchWritingViewModel {
    private let persistenceService = PersistenceService.shared
    private let firebaseService = FirebaseService()

    // 플레이리스트 정보
    var playlist = SwiftDataPlaylistModel()
    var diggingList: [SongModel] = []
    var userTitle: String = ""
    var userDescription: String = ""
    
    // 커버 이미지
    var photoURL: String = ""
    var photoUIImage: UIImage?
    var currentDate: String = ""
    var currentLocality: String = ""
    var currentRegion: String = ""
    var showSheet: Bool = false
    
    // 커버 이미지 - 앨범에서 가져오기
    var selectedItem: PhotosPickerItem?
    var selectedImageData: Data?
    var showPhotoPicker: Bool = false
    
    // 유저 위치
    var currentLatitude: Double?
    var currentLongitude: Double?
    var currentStreetAddress: String?
    var placeHolderAddress: String = ""
    
    // 저장 상태 관리
    var isSaving: Bool = false
    
    init(currentLatitude: Double? = nil,
         currentLongitude: Double? = nil,
         currentStreetAddress: String? = nil,
         placeHolderAddress: String = "",
         userTitle: String = "",
         currentLocality: String = "",
         currentRegion: String = "") {
        self.currentLatitude = currentLatitude
        self.currentLongitude = currentLongitude
        self.currentStreetAddress = currentStreetAddress
        self.placeHolderAddress = placeHolderAddress
        if userTitle == "" {
            self.userTitle = placeHolderAddress
        } else {
            self.userTitle = userTitle
        }

        self.currentLocality = currentLocality
        self.currentRegion = currentRegion
        
        loadSavedSongs()
        setCurrentDate()
    }
    
    func loadSavedSongs() {
        do {
            self.diggingList = try persistenceService.loadDiggingListWithOrder()
        } catch {
            print("Failed to load saved songs: \(error)")
        }
    }
    
    func savedPlaylist() async -> Bool {
        isSaving = true
        defer { isSaving = false }
        
        do {
            guard let currentLatitude = self.currentLatitude,
                  let currentLongitude = self.currentLongitude,
                  let currentStreetAddress = self.currentStreetAddress else { return false }
            
            userTitle = userTitle == "" ? placeHolderAddress : userTitle
            
            try persistenceService.createPlaylist(playlistName: userTitle,
                                                  playlistDescription: userDescription,
                                                  photoURL: photoURL,
                                                  latitude: currentLatitude,
                                                  longitude: currentLongitude,
                                                  streetAddress: currentStreetAddress)
            playlist.playlistName = userTitle
            playlist.playlistDescription = userDescription
            playlist.songs = try persistenceService.fetchDiggingList()
            playlist.photoURL = photoURL
            playlist.latitude = currentLatitude
            playlist.longitude = currentLongitude
            playlist.streetAddress = currentStreetAddress
            
            await playlist.photoURL = savePhotoToFirebase(userID: FirebaseAuthService.currentUID ?? "") ?? ""
            try await firebaseService.savePlaylistToFirebase(userID: FirebaseAuthService.currentUID ?? "",
                                                             playlist: ModelAdapter.toFirestorePlaylist(from: playlist))
            return true
        } catch {
            print("Failed to create playlist: \(error)")
            return false
        }
    }
    
    func clearDiggingList() {
        do {
            diggingList.removeAll()
            try persistenceService.deleteAllSongs()
        } catch {
            print("Failed to clear songs: \(error)")
        }
    }
    
    func savePhotoUIImage(photoUIImage: UIImage) {
        self.photoUIImage = photoUIImage
    }
    
    func savePhotoToFirebase(userID: String) async -> String? {
        if let image = photoUIImage {
            do {
                photoURL = try await firebaseService.uploadImageToFirebase(userID: userID, image: image)
            } catch {
                print("이미지 저장 실패: \(error.localizedDescription)")
            }
        }
        return photoURL
    }
    
    func setCurrentDate() {
        let today = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        
        self.currentDate = dateFormatter.string(from: today)
    }

    // 앨범에서 불러오기
    func loadImageFromGallery() async {
        if let data = try? await selectedItem?.loadTransferable(type: Data.self) {
            selectedImageData = data
            photoUIImage = UIImage(data: data)?.cropSquare()
        }
    }
}
