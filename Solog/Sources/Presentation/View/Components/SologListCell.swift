//
//  SologListCell.swift
//  Solog
//
//  Created by 박현수 on 3/18/25.
//

import SwiftUI
import Kingfisher

struct SologListCell: View {
    private let playlist: PlaylistModel
    private let size: CGSize
    private let action: () -> Void
    private var imageHeight: CGFloat { (size.width - 20) * 157 / 341 }
    private var dateAsString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM월 dd일"
        return dateFormatter.string(from: playlist.generationTime)
    }

    init(
        playlist: PlaylistModel,
        size: CGSize,
        action: @escaping () -> Void
    ) {
        self.playlist = playlist
        self.size = size
        self.action = action
    }

    var body: some View {
        Button {
            action()
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                KFImage(URL(string: playlist.photoURL))
                    .resizable()
                    .cancelOnDisappear(true)
                    .placeholder {
                        Image(.sologPlaceholder)
                            .resizable()
                    }
                    .scaledToFill()
                    .frame(height: imageHeight)
                    .clipped()
                    .padding(.vertical, 15)

                Text(playlist.playlistName)
                    .font(.sCoreDream(weight: .dream5, size: 20))
                    .foregroundStyle(Color(.sTitleText))

                Divider()
                    .frame(height: 0.5)
                    .foregroundStyle(Color(.sLine))
                    .padding(.bottom, 6)

                HStack(spacing: 0) {
                    Text(Image(systemName: "music.note"))
                        .font(.system(size: 15))
                        .foregroundStyle(Color(.sSubHead))
                        .padding(.trailing, 2)
                    Text("수집한 음악")
                        .font(.notoSansKR(weight: .regular400, size: 15))
                        .foregroundStyle(Color(.sSubHead))
                        .padding(.trailing, 8)
                    Text("\(playlist.songs.count)곡")
                        .font(.notoSansKR(weight: .medium500, size: 15))
                        .foregroundStyle(Color(.sTitleText))
                }

                Divider()
                    .frame(height: 0.5)
                    .foregroundStyle(Color(.sLine))
                    .padding(.vertical, 6)

                Text(dateAsString)
                    .font(.notoSansKR(weight: .regular400, size: 12))
                    .foregroundStyle(Color(.sFootNote))
                    .padding(.bottom, 10)
            }
            .padding(.horizontal, 10)
            .background(Color(.sWhite))
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .shadow(color: Color(.sBlack).opacity(0.15), radius: 3, x: 0, y: 1)
        }
    }
}
