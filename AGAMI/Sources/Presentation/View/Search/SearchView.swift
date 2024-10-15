//
//  SearchView.swift
//  AGAMI
//
//  Created by Seoyeon Choi on 10/15/24.
//

import SwiftUI

struct SearchView: View {
    var body: some View {
        VStack(spacing: 0) {
            SearchTopView()
                .padding(.bottom, 28)
            SearchPlaylistView()
        }
        .toolbar {
            ToolbarItem(placement: .principal, content: {
                Text("수집하기")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(.black)
                    .kerning(-0.4)
            })
            
            ToolbarItem(placement: .topBarTrailing, content: {
                Text("다음")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(.blue)
            })
        }
    }
    
    struct SearchTopView: View {
        var body: some View {
            VStack {
                Circle()
                    .frame(width: 226, height: 226)
                    .foregroundStyle(.secondary)
                    .overlay {
                        Circle()
                            .frame(width: 74, height: 74)
                            .foregroundStyle(.placeholder)
                    }
                    .padding(.bottom, 15)
                
                Text("Listening ...")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(.black)
            }
        }
    }
    
    struct SearchPlaylistView: View {
        var dummyPlaylist: [DummySongModel] = Array(repeating: .init(), count: 10)
        
        var body: some View {
            HStack(spacing: 0) {
                Spacer()
                
                Text("전체 삭제")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(.gray.opacity(0.8))
                    .padding(.trailing, 16)
                    .padding(.bottom, 8)
            }
            
            Divider()
            
            List {
                ForEach(dummyPlaylist) { song in
                    PlaylistRow(song: song)
                }
            }
            .listStyle(.plain)
            .scrollIndicators(.hidden)
            .scaledToFit()
        }
    }
}

#Preview {
    SearchView()
}
