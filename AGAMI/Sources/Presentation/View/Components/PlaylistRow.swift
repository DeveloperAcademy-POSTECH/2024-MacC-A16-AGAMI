//
//  PlaylistRow.swift
//  AGAMI
//
//  Created by Seoyeon Choi on 10/15/24.
//

import SwiftUI

import Kingfisher

struct PlaylistRow: View {
    let song: SongModel

    var body: some View {
        HStack(spacing: 0) {
            KFImage(URL(string: song.albumCoverURL))
                .resizable()
                .cancelOnDisappear(true)
                .placeholder({
                    ProgressView()
                        .frame(width: 60, height: 60)
                })
                .frame(width: 60, height: 60)
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
                .foregroundStyle(Color(.pGray3))
                .font(.system(size: 16, weight: .regular))
                .padding(.trailing, 15)
        }
    }
}
