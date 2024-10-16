//
//  SearchWritingViewModel.swift
//  AGAMI
//
//  Created by Seoyeon Choi on 10/16/24.
//

import Foundation

@Observable
final class SearchWritingViewModel {
    var showPlaylistModal: Bool = false
    var userTitle: String = ""
    var userDescription: String = ""
    
    func showPlaylistButtonTapped() {
        showPlaylistModal.toggle()
    }
}
