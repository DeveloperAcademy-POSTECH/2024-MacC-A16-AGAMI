//
//  ArchiveListViewModel.swift
//  AGAMI
//
//  Created by 박현수 on 10/14/24.
//

import Foundation

@Observable
final class ArchiveListViewModel {
    let dummyURL: URL? = .init(string: "https://dummyimage.com/400x400/000/fff")

    var selectedCard: Int?
    var currentId: Int?

    func isCurrent(_ index: Int) -> Bool {
        currentId == index
    }

    func setSelectedCard(_ index: Int?) {
        selectedCard = index
    }

    func setCurrentId(_ index: Int?) {
        currentId = index
    }

    func getCardsPadding(_ index: Int, size: CGSize) -> CGFloat {
        currentId == index ? size.width * 0.4 : -size.width * 0.3
    }
}