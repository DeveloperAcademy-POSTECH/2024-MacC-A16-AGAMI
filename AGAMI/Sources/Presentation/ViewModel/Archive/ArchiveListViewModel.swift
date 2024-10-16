//
//  ArchiveListViewModel.swift
//  AGAMI
//
//  Created by 박현수 on 10/14/24.
//

import Foundation

@Observable
final class ArchiveListViewModel {
    let dummyURL: URL? = .init(string: "https://dummyimage.com/400x400/fff/000")

    var selectedCard: Int?
    var currentId: Int?

    var searchText: String = ""

    func isCurrent(_ index: Int) -> Bool {
        currentId == index
    }

    func setSelectedCard(_ index: Int?) {
        selectedCard = index
    }

    func setCurrentId(_ index: Int?) {
        currentId = index
    }
}
