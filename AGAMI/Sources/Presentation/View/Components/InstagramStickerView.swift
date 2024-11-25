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
                    .padding(.horizontal, 36)
            } else {
                Image(.sologPlaceholder)
                    .resizable()
                    .aspectRatio(1, contentMode: .fill)
                    .clipped()
                    .padding(.horizontal, 36)
            }
        }
    }
}

private struct WithOneSong: View {
    let playlist: PlaylistModel
    let images: [UIImage]

    var body: some View {
        let title = playlist.songs.last?.title
        let address = playlist.streetAddress.split(separator: ",").first?.trimmingCharacters(in: .whitespacesAndNewlines)

        VStack(alignment: .leading, spacing: 0) {
            StickerImage(uiImage: images.first)
                .padding(.top, 70)

            Spacer()

            Text("\(title ?? "")")
                .font(.pretendard(weight: .medium500, size: 24))
                .foregroundStyle(Color(.pGray1))
                .padding(.bottom, 6)

            Text("\(address ?? "")에서\n수집한 플레이크입니다.")
                .font(.pretendard(weight: .bold700, size: 32))
                .foregroundStyle(Color(.pWhite))
                .multilineTextAlignment(.leading)
                .lineSpacing(4)
                .padding(.bottom, 32)
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
            ZStack {
                Group {
                    StickerImage(uiImage: images.first)
                        .rotationEffect(.degrees(-5.98))
                        .offset(x: -64)
                    StickerImage(uiImage: images.last)
                        .rotationEffect(.degrees(8.03))
                        .offset(x: 64, y: 96)
                }
                .padding(.horizontal, 32)

            }
            .aspectRatio(1, contentMode: .fit)
            .padding(.top, 70)

            Spacer()

            Text("\(title ?? "") 외 1곡")
                .font(.pretendard(weight: .medium500, size: 24))
                .foregroundStyle(Color(.pGray1))
                .padding(.bottom, 6)

            Text("\(address ?? "")에서\n수집한 플레이크입니다.")
                .font(.pretendard(weight: .bold700, size: 32))
                .foregroundStyle(Color(.pWhite))
                .multilineTextAlignment(.leading)
                .lineSpacing(4)
                .padding(.bottom, 32)
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
            ZStack {
                Group {
                    StickerImage(uiImage: images.first)
                        .rotationEffect(.degrees(0.86))
                        .offset(x: 20, y: -40)
                    StickerImage(uiImage: images.dropLast(1).last)
                        .rotationEffect(.degrees(-12.4))
                        .offset(x: -48, y: 64)
                    StickerImage(uiImage: images.last)
                        .rotationEffect(.degrees(3.28))
                        .offset(x: 48, y: 96)
                }
                .padding(.horizontal, 32)
            }
            .aspectRatio(1, contentMode: .fit)
            .padding(.top, 70)

            Spacer()

            Text("\(title ?? "") 외 2곡")
                .font(.pretendard(weight: .medium500, size: 24))
                .foregroundStyle(Color(.pGray1))
                .padding(.bottom, 6)

            Text("\(address ?? "")에서\n수집한 플레이크입니다.")
                .font(.pretendard(weight: .bold700, size: 32))
                .foregroundStyle(Color(.pWhite))
                .multilineTextAlignment(.leading)
                .lineSpacing(4)
                .padding(.bottom, 32)
        }
        .instagramStickerStyle()
    }
}
