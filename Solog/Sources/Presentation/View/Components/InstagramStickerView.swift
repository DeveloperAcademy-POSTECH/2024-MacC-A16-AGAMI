//
//  InstagramStickerView.swift
//  AGAMI
//
//  Created by 박현수 on 11/17/24.
//

import SwiftUI

struct InstagramStickerView: View {
    let playlist: PlaylistModel
    let images: [UIImage]

    var body: some View {
        switch images.count {
        case ...0:
            EmptyView()
        case 1:
            WithOneSong(playlist: playlist, images: images)
        case 2:
            WithTwoSongs(playlist: playlist, images: images)
        default:
            WithMultipleSongs(playlist: playlist, images: images)
        }
    }
}

private struct StickerImage: View {
    let uiImage: UIImage?
    var body: some View {
        ZStack {
            Image(.sharePhotoHolder)
                .resizable()
                .aspectRatio(1, contentMode: .fit)
                .shadow(radius: 10)
            if let image = uiImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .padding(.horizontal, 32)
            } else {
                Image(.sologPlaceholder)
                    .resizable()
                    .aspectRatio(1, contentMode: .fill)
                    .clipped()
                    .padding(.horizontal, 32)
            }
        }
    }
}

private struct LogoRow: View {
    var body: some View {
        HStack(alignment: .center, spacing: 6) {
            Image(.sologListIcon)
                .resizable()
                .frame(width: 40, height: 40)
            Text("소록")
                .font(.sCoreDream(weight: .dream5, size: 26))
                .foregroundStyle(Color(.sMain))
            Spacer()

        }
        .padding(EdgeInsets(top: 20, leading: -24, bottom: 24, trailing: -24))
    }
}

private struct WithOneSong: View {
    let playlist: PlaylistModel
    let images: [UIImage]

    var body: some View {
        let title = playlist.songs.last?.title
        let address = playlist.streetAddress.split(separator: ",").first?.trimmingCharacters(in: .whitespacesAndNewlines)

        VStack(alignment: .leading, spacing: 0) {
            LogoRow()

            StickerImage(uiImage: images.first)
                .padding(.horizontal, 16)

            Spacer()

            Text("\(title ?? "")")
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(Color(.sBodyText))
                .lineLimit(1)
                .padding(.bottom, 6)

            Text("'\(address ?? "")'에서\n수집한 노래 기록입니다.")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(Color(.sWhite))
                .multilineTextAlignment(.leading)
                .lineSpacing(4)
                .padding(.bottom, 48)
        }
        .instagramStickerStyle()
    }
}

private struct WithTwoSongs: View {
    let playlist: PlaylistModel
    let images: [UIImage]

    var body: some View {
        let title = playlist.songs.last?.title
        let address = playlist.streetAddress.split(separator: ",").first?.trimmingCharacters(in: .whitespacesAndNewlines)

        VStack(alignment: .leading, spacing: 0) {
            LogoRow()

            ZStack {
                Group {
                    StickerImage(uiImage: images.first)
                        .rotationEffect(.degrees(-5.98))
                        .offset(x: -64)
                    StickerImage(uiImage: images.last)
                        .rotationEffect(.degrees(8.03))
                        .offset(x: 64, y: 96)
                }
                .padding(.horizontal, 56)

            }
            .aspectRatio(1, contentMode: .fit)

            Spacer()

            Text("\(title ?? "") 외 1곡")
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(Color(.sBodyText))
                .lineLimit(1)
                .padding(.bottom, 6)

            Text("'\(address ?? "")'에서\n수집한 노래 기록입니다.")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(Color(.sWhite))
                .multilineTextAlignment(.leading)
                .lineSpacing(4)
                .padding(.bottom, 48)
        }
        .instagramStickerStyle()
    }
}

private struct WithMultipleSongs: View {
    let playlist: PlaylistModel
    let images: [UIImage]

    var body: some View {
        let title = playlist.songs.last?.title
        let address = playlist.streetAddress.split(separator: ",").first?.trimmingCharacters(in: .whitespacesAndNewlines)

        VStack(alignment: .leading, spacing: 0) {
            LogoRow()

            ZStack {
                Group {
                    StickerImage(uiImage: images.first)
                        .rotationEffect(.degrees(0.86))
                        .offset(x: 20, y: -20)
                    StickerImage(uiImage: images.dropLast(1).last)
                        .rotationEffect(.degrees(-12.4))
                        .offset(x: -48, y: 64)
                    StickerImage(uiImage: images.last)
                        .rotationEffect(.degrees(3.28))
                        .offset(x: 48, y: 96)
                }
                .padding(.horizontal, 56)
            }
            .aspectRatio(1, contentMode: .fit)

            Spacer()

            Text("\(title ?? "") 외 \(playlist.songs.count - 1)곡")
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(Color(.sBodyText))
                .lineLimit(1)
                .padding(.bottom, 6)

            Text("'\(address ?? "")'에서\n수집한 노래 기록입니다.")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(Color(.sWhite))
                .multilineTextAlignment(.leading)
                .lineSpacing(4)
                .padding(.bottom, 48)
        }
        .instagramStickerStyle()
    }
}
