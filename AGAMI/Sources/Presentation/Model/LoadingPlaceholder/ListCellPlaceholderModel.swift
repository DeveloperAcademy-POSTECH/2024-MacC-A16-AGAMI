//
//  ListCellPlaceholderModel.swift
//  AGAMI
//
//  Created by taehun on 11/4/24.
//

import Foundation

final class ListCellPlaceholderModel {
    private init() {}
    static let shared = ListCellPlaceholderModel()
    var name: String?
    var streetAddress: String?
    var generationTime: Date?
}
