//
//  CollectionPlaceViewModel.swift
//  AGAMI
//
//  Created by yegang on 10/15/24.
//

import Foundation

@Observable
final class CollectionPlaceViewModel: Hashable {
    let id = UUID()
    let playlists: [PlaylistModel]
    
    init(playlists: [PlaylistModel]) {
        self.playlists = playlists
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: CollectionPlaceViewModel, rhs: CollectionPlaceViewModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func formatDateToString(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy. MM. dd."
        return dateFormatter.string(from: date)
    }
}
