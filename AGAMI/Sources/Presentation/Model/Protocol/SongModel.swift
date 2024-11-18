//
//  SongModel.swift
//  AGAMI
//
//  Created by 박현수 on 10/19/24.
//
import Foundation

protocol SongModel {
    var songID: String { get }
    var title: String { get set }
    var artist: String { get set }
    var albumCoverURL: String { get set }
    var orderIndex: Int? { get set }
}
