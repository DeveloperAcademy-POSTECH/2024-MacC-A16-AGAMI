//
//  SearchPlayListFullscreenVIew.swift
//  AGAMI
//
//  Created by Seoyeon Choi on 10/20/24.
//

import SwiftUI

struct SearchPlayListFullscreenVIew: View {
    @Environment(SearchCoordinator.self) var coordinator
    var viewModel: SearchWritingViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Text("방금 수집한 플레이크")
                    .font(.system(size: 24, weight: .bold))
                
                Spacer()
                
                Button {
                    coordinator.dismissFullScreenCover()
                } label: {
                    Image(.dismissButton)
                        .resizable()
                        .frame(width: 34, height: 34)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 40)
            
            Section(header: HStack {
                Text("\(viewModel.diggingList.count) 플레이크")
                    .font(.system(size: 16, weight: .semibold))
                    .kerning(0.4)
                    .padding(.vertical, 13)
                    .padding(.leading, 16)
                Spacer()
            }) {
                List {
                    ForEach(viewModel.diggingList, id: \.songID) { song in
                        PlaylistRow(song: song)
                    }
                }
                .scrollIndicators(.hidden)
            }
        }
    }
}
