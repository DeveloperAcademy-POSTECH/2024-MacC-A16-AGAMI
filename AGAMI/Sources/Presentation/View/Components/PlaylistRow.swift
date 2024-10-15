//
//  PlaylistRow.swift
//  AGAMI
//
//  Created by Seoyeon Choi on 10/15/24.
//

import SwiftUI

struct PlaylistRow: View {
    let song: DummySongModel
    
    var body: some View {
        HStack {
            AsyncImage(url: song.imageURL) { image in
                image
                    .resizable()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

            } placeholder: {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.black)
                    .frame(width: 60, height: 60)
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

#Preview {
    PlaylistRow(song: DummySongModel())
}
