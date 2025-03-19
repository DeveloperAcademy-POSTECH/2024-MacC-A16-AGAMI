//
//  PlaylistRow.swift
//  AGAMI
//
//  Created by Seoyeon Choi on 10/15/24.
//

import SwiftUI

import Kingfisher

struct PlaylistRow: View {
    private let song: SongModel
    private let isHighlighted: Bool
    private let isEditing: Bool

    init(song: SongModel, isHighlighted: Bool = false, isEditing: Bool = false) {
        self.song = song
        self.isHighlighted = isHighlighted
        self.isEditing = isEditing
    }

    var body: some View {
        HStack(spacing: 0) {
            if !song.albumCoverURL.isEmpty {
                KFImage(URL(string: song.albumCoverURL))
                    .resizable()
                    .cancelOnDisappear(true)
                    .placeholder { ProgressView() }
                    .frame(width: 60, height: 60)
                    .padding(.trailing, 12)
            } else {
                Image(.songEmpty)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .padding(.trailing, 12)
            }

            VStack(alignment: .leading) {
                Text(song.title)
                    .font(.notoSansKR(weight: .medium500, size: 16))
                    .kerning(-0.3)
                    .foregroundStyle(Color(.sTitleText))
                    .lineLimit(1)

                Text(song.artist)
                    .font(.notoSansKR(weight: .regular400, size: 14))
                    .foregroundStyle(Color(.sBodyText))
                    .kerning(-0.3)
                    .lineLimit(1)
            }

            Spacer()

            if isEditing {
                Image(systemName: "line.3.horizontal")
                    .foregroundStyle(.gray)
                    .font(.system(size: 16, weight: .regular))
                Spacer().frame(width: 16)
            }
        }
        .background(isHighlighted ? Color(.sListBack) : .clear)
    }
}
