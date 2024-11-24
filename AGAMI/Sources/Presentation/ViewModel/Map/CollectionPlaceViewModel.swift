//
//  CollectionPlaceViewModel.swift
//  AGAMI
//
//  Created by yegang on 10/15/24.
//

import Foundation

@Observable
final class CollectionPlaceViewModel {
    let playlists: [PlaylistModel]
    
    init(playlists: [PlaylistModel]) {
        self.playlists = playlists
    }

    func formatDateToString(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM월 dd일"
        return dateFormatter.string(from: date)
    }
}
