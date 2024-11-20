//
//  CoordinatorViewModelContainer.swift
//  AGAMI
//
//  Created by 박현수 on 11/3/24.
//

enum CoordinatorViewModelContainer: Hashable {
    var id: String {
        switch self {
        case .searchAddSongView:
            return "searchAddSongView"
        case .plakePlaylist:
            return "plakePlaylist"
        }
    }

    static func == (lhs: CoordinatorViewModelContainer, rhs: CoordinatorViewModelContainer) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    case searchAddSongView(viewModel: SearchAddSongViewModel)
    case plakePlaylist(viewModel: PlakePlaylistViewModel)
}
