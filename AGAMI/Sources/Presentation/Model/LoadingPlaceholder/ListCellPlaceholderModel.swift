//
//  ListCellPlaceholderModel.swift
//  AGAMI
//
//  Created by taehun on 11/4/24.
//

import Foundation

@Observable
final class ListCellPlaceholderModel {
    var name: String?
    var streetAddress: String?
    var generationTime: Date?

    var shouldShowUploadingCell: Bool {
        return name != nil && streetAddress != nil && generationTime != nil
    }

    func initializePropertyValues() {
        self.name = nil
        self.streetAddress = nil
        self.generationTime = nil
    }
    
    func setPropertyValues(userTitle: String, streetAddress: String, generationTime: Date) {
        self.name = userTitle
        self.streetAddress = streetAddress
        self.generationTime = generationTime
    }
}
