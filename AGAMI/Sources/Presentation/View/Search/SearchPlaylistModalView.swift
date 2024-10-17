//
//  SearchPlaylistModalView.swift
//  AGAMI
//
//  Created by Seoyeon Choi on 10/16/24.
//

import SwiftUI

struct SearchPlaylistModalView: View {
    var navigationTitle: String
    var diggingList: [SongModel]?
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    if let diggingList = diggingList {
                        ForEach(diggingList) { song in
                            PlaylistRow(song: song)
                        }
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
    SearchPlaylistModalView(navigationTitle: "구리스", diggingList: [])
}
