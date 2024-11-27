//
//  SearchListViewModel.swift
//  AGAMI
//
//  Created by 박현수 on 11/24/24.
//

import Foundation

@Observable
final class SearchListViewModel {
    var playlists: [PlaylistModel] {
        if searchText.isEmpty {
            unfilteredPlaylists
        } else {
            unfilteredPlaylists.filter {
                $0.playlistName.lowercased().contains(searchText.lowercased())
            }
        }
    }
    private var unfilteredPlaylists: [PlaylistModel]

    var isSearchBarPresented: Bool = false

    var searchText: String = "" {
        didSet {
            keyboardHaptic()
        }
    }

    var hasNoResult: Bool {
        playlists.isEmpty && !searchText.isEmpty
    }

    init(playlists: [PlaylistModel]) {
        self.unfilteredPlaylists = playlists
    }

    func clearSearchText() {
        searchText.removeAll()
    }

    func simpleHaptic() {
        HapticService.shared.playSimpleHaptic()
    }

    func keyboardHaptic() {
        HapticService.shared.playKeyboardHaptic()
    }

    func formatDateToString(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM월 dd일"
        return dateFormatter.string(from: date)
    }
}
