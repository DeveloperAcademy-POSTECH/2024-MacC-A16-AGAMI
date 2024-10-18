//
//  PersistenceService.swift
//  AGAMI
//
//  Created by 박현수 on 10/18/24.
//

import Foundation

protocol PersistenceService {
    func createPlaylist()
    func fetchPlaylist()
    func deletePlaylist()
}
