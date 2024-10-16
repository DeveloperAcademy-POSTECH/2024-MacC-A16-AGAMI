//
//  SearchPlaylistModalView.swift
//  AGAMI
//
//  Created by Seoyeon Choi on 10/16/24.
//

import SwiftUI

struct SearchPlaylistModalView: View {
    var dummyPlaylist: [DummySongModel] = Array(repeating: .init(), count: 10)
    var navigationTitle: String
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(dummyPlaylist) { song in
                        PlaylistRow(song: song)
                    }
                }
                .listStyle(PlainListStyle())
                .scrollIndicators(.hidden)
            }
            .navigationTitle(navigationTitle)
        }
    }
}

#Preview {
    SearchPlaylistModalView(navigationTitle: "구리스")
}
