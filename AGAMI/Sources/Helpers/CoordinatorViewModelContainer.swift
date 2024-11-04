//
//  CoordinatorViewModelContainer.swift
//  AGAMI
//
//  Created by 박현수 on 11/3/24.
//

enum CoordinatorViewModelContainer: Hashable {
    var id: String {
        switch self {
        case .searchWriting:
            return "searchWriting"
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

    case searchWriting(viewModel: SearchWritingViewModel)
    case plakePlaylist(viewModel: PlakePlaylistViewModel)
}
