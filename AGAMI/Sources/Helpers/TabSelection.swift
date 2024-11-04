//
//  TabSelection.swift
//  AGAMI
//
//  Created by 박현수 on 10/31/24.
//

enum TabSelection: Hashable {
    case plake
    case map
    
    var title: String {
        switch self {
        case .plake: return "Plake"
        case .map: return "Map"
        }
    }
}
