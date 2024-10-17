//
//  PlaylistRow.swift
//  AGAMI
//
//  Created by Seoyeon Choi on 10/15/24.
//

import SwiftUI

struct PlaylistRow: View {
    let song: SongModel
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: song.albumCoverURL)) { image in
                image
                    .resizable()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

            } placeholder: {
                ProgressView()
            }
            .padding(.trailing, 10)

            VStack(alignment: .leading) {
                Text(song.title)
                    .font(.system(size: 20))
                Text(song.artist)
                    .font(.system(size: 16))
                    .foregroundStyle(.gray)
            }
        }
    }
}
