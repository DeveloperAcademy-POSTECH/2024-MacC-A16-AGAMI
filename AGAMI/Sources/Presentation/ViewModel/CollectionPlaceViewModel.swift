//
//  CollectionPlaceViewModel.swift
//  AGAMI
//
//  Created by yegang on 10/15/24.
//

import Foundation

struct PlayList: Identifiable, Hashable {
    var id = UUID()
    var address: String
    var date: String
    var time: String
}

@Observable
final class CollectionPlaceViewModel {    
    var playList: [PlayList] = [
        PlayList(address: "포항시", date: "2024-03-02", time: "17:00"),
        PlayList(address: "천안시", date: "2023-03-01", time: "13:00"),
        PlayList(address: "서울시", date: "2020-05-05", time: "10:00")
    ]
}
