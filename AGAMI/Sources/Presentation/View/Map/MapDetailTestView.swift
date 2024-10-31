//
//  MapDetailTestView.swift
//  AGAMI
//
//  Created by 박현수 on 10/31/24.
//

import SwiftUI

struct MapDetailTestView: View {
    var playlists: [PlaylistModel]
    var body: some View {
        List {
            ForEach(playlists, id: \.playlistID) { playlist in
                Text(playlist.playlistName)
            }
        }
    }
}
