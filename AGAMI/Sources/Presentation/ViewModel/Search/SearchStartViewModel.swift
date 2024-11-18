//
//  SearchStartViewModel.swift
//  AGAMI
//
//  Created by Seoyeon Choi on 10/16/24.
//

import SwiftUI
import CoreLocation

@Observable
final class SearchStartViewModel {
    private let persistenceService = PersistenceService.shared
    private let locationService = LocationService.shared
    
    // 유저 위치
    var currentLatitude: Double?
    var currentLongitude: Double?
    var currentStreetAddress: String?
    var currentLocality: String = ""
    var currentRegion: String = ""
    
    // 플레이크 타이틀
    var placeHolderAddress: String = ""
    var isLoaded: Bool = false
    var userTitle: String = ""
    
    // 수집한 노래
    var diggingList: [SongModel] = []
    
    var showBackButtonAlert: Bool = false
    
    init() {
        loadSavedSongs()
    }
    
    func initializeView() {
        loadSavedSongs()
        Task {
            await fetchCurrentLocation()
        }
    }
    
    func createSearchWritingViewModel() -> SearchWritingViewModel {
        return SearchWritingViewModel(
            currentLatitude: currentLatitude,
            currentLongitude: currentLongitude,
            currentStreetAddress: currentStreetAddress,
            placeHolderAddress: placeHolderAddress,
            userTitle: userTitle,
            currentLocality: currentLocality,
            currentRegion: currentRegion
        )
    }
    
    func loadSavedSongs() {
        do {
            self.diggingList = try persistenceService.loadDiggingListWithOrder()
        } catch {
            dump("저장된 노래를 불러오는 데 실패했습니다: \(error)")
        }
    }

    func fetchCurrentLocation() async {
        do {
            let location = try await locationService.requestCurrentLocation()
            currentLatitude = location.coordinate.latitude
            currentLongitude = location.coordinate.longitude
            await fetchCurrentStreetAddress()
        } catch {
            dump("현재 위치를 가져오는 데 실패했습니다: \(error)")
        }
    }
    
    func fetchCurrentStreetAddress() async {
        if let address = await locationService.coordinateToStreetAddress() {
            currentStreetAddress = address
            setPlaceHolderAddress()
            if currentLatitude != nil && currentLongitude != nil && currentStreetAddress != nil {
                isLoaded = true
            }
        }
    }
    
    func setPlaceHolderAddress() {
        if let address = locationService.placeHolderAddress {
            if let range = address.range(of: "로") ?? address.range(of: "길") {
                placeHolderAddress = String(address[..<range.upperBound])
                placeHolderAddress += "에서 만난 플레이크"
            } else {
                placeHolderAddress = address
                placeHolderAddress += "에서 만난 플레이크"
            }
            self.currentRegion = address
            
            if let locality = locationService.locality {
                self.currentLocality = locality
            }
        }
    }
    
    func deleteSong(indexSet: IndexSet) {
        for index in indexSet {
            let songToDelete = diggingList[index]
            diggingList.remove(at: index)
            
            if let song = songToDelete as? SwiftDataSongModel {
                do {
                    try persistenceService.deleteSong(item: song)
                    loadSavedSongs()
                } catch {
                    dump("노래 삭제 중 오류 발생: \(error)")
                }
            } else {
                dump("오류: Song이 SwiftDataSongModel 타입이 아닙니다")
            }
        }
    }
    
    func moveSong(from source: IndexSet, to destination: Int) {
        diggingList.move(fromOffsets: source, toOffset: destination)
        persistenceService.saveDiggingListOrder(diggingList)
    }
    
    func clearDiggingList() {
        do {
            diggingList.removeAll()
            try persistenceService.deleteAllSongs()
        } catch {
            dump("Failed to clear songs: \(error)")
        }
    }
}
