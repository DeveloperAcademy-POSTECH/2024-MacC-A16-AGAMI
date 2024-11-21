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
    let isHighlighted: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            if !song.albumCoverURL.isEmpty {
                KFImage(URL(string: song.albumCoverURL))
                    .resizable()
                    .cancelOnDisappear(true)
                    .placeholder({
                        ProgressView()
                            .frame(width: 54, height: 54)
                    })
                    .frame(width: 54, height: 54)
                    .padding(.trailing, 20)
                    .padding(.vertical, 3)
            } else {
                Image(.songEmpty)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 54, height: 54)
                    .padding(.trailing, 20)
                    .padding(.vertical, 3)
            }
            
            VStack(alignment: .leading, spacing: 0) {
                Text(song.title)
                    .font(.pretendard(weight: .medium500, size: 16))
                    .kerning(-0.3)
                    .foregroundStyle(Color(.sTitleText))
                
                Text(song.artist)
                    .font(.pretendard(weight: .regular400, size: 14))
                    .kerning(-0.3)
                    .foregroundStyle(Color(.sBodyText))
            }
            Spacer()
        }
        .background(isHighlighted ? Color(.sListBack) : .clear)
    }
}
