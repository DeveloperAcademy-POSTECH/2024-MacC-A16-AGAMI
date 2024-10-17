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
        HStack(spacing: 0) {
            AsyncImage(url: URL(string: song.albumCoverURL)) { image in
                image
                    .resizable()
                    .frame(width: 60, height: 60)

            } placeholder: {
                ProgressView()
            }
            .padding(.trailing, 20)

            VStack(alignment: .leading, spacing: 0) {
                Text(song.title)
                    .font(.system(size: 17, weight: .semibold))
                    .kerning(-0.43)
                
                Text(song.artist)
                    .font(.system(size: 15, weight: .regular))
                    .kerning(-0.23)
                    .foregroundStyle(.gray)
            }
            
            Spacer()
            
            Image(systemName: "line.3.horizontal")
                .foregroundStyle(.gray)
                .font(.system(size: 16, weight: .regular))
                .padding(.trailing, 15)
        }
    }
}
