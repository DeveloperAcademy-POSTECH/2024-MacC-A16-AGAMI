//
//  SongDetailView.swift
//  AGAMI
//
//  Created by Seoyeon Choi on 11/25/24.
//

import SwiftUI
import Kingfisher

struct SongDetailView: View {
    let detailSong: DetailSong?
    let isLoading: Bool
    let dismiss: (() -> Void)?
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .onTapGesture {
                    dismiss?()
                }
                .disabled(isLoading)
            
            if isLoading || detailSong == nil {
                ProgressView()
            } else {
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        Spacer()
                        Image(systemName: "xmark.circle")
                            .font(.system(size: 21, weight: .light))
                            .padding(EdgeInsets(top: 14, leading: 0, bottom: 0, trailing: 11))
                            .onTapGesture {
                                dismiss?()
                            }
                    }
                    .padding(.vertical, 0)
                    .padding(.horizontal, 0)
                    
                    if let url = URL(string: detailSong?.albumCoverURL ?? "") {
                        KFImage(url)
                            .resizable()
                            .placeholder { ProgressView() }
                            .frame(width: 155, height: 155)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    } else {
                        Image(systemName: "music.note")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 155, height: 155)
                            .background(Color.gray)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                            .padding(.top, 33)
                    }
                    
                    Text(detailSong?.songTitle ?? "")
                        .font(.notoSansKR(weight: .bold700, size: 24))
                        .padding(.horizontal, 18)
                        .padding(.top, 18)
                    
                    HorizontalDivider()
                        .padding(.top, 18)
                    
                    DetailInformationRow(title: "아티스트", value: detailSong?.artist)
                    DetailInformationRow(title: "앨범", value: detailSong?.albumTitle)
                    DetailInformationRow(title: "장르", value: detailSong?.genres?.joined(separator: ", "))
                    DetailInformationRow(title: "발매일", value: detailSong?.releaseDate)
                }
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .padding(.horizontal, 10)
            }
        }
        .ignoresSafeArea()
    }
}

struct DetailInformationRow: View {
    let title: String
    let value: String?
    
    var body: some View {
        if let value = value {
            HStack(alignment: .top, spacing: 0) {
                Text(title)
                    .font(.notoSansKR(weight: .medium500, size: 15))
                    .foregroundStyle(Color(.sSubHead))
                    .frame(width: 56, alignment: .leading)
                    .padding(.horizontal, 0)
                    .padding(.vertical, 0)
                
                Text(value)
                    .font(.notoSansKR(weight: .regular400, size: 17))
                    .foregroundStyle(Color(.sTitleText))
                    .multilineTextAlignment(.leading)
                    .padding(0)
                    .overlay(alignment: .leading) {
                        Divider()
                            .offset(x: -11)
                    }
                    .padding(.leading, 29)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 18)
            .padding(.vertical, 0)
            
            HorizontalDivider()
        }
    }
}

struct HorizontalDivider: View {
    var body: some View {
        Divider()
            .foregroundStyle(Color(.sLine))
            .padding(.horizontal, 18)
            .padding(.vertical, 7)
    }
}
