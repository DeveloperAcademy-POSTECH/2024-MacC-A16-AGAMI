//
//  SearchView.swift
//  AGAMI
//
//  Created by Seoyeon Choi on 10/15/24.
//

import SwiftUI

struct SearchView: View {
    @State private var isFind: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: {
                isFind.toggle()
            }, label: {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(.gray.opacity(0.3))
                    .overlay {
                        Text(isFind ? "서치 중" : "서치 시작")
                    }
                    .frame(width: 260, height: 100)
            })
        }
    }
    
    struct SearchTopView: View {
        @Binding var isFind: Bool
        
        var body: some View {
            VStack(spacing: 0) {
                Circle()
                    .frame(width: 226, height: 226)
                    .foregroundStyle(.secondary)
                    .overlay {
                        Circle()
                            .frame(width: 74, height: 74)
                            .foregroundStyle(isFind ? Color.gray : Color.white )
                            .overlay {
                                if isFind {
                                    Image(systemName: "arrow.trianglehead.counterclockwise")
                                        .foregroundStyle(.white)
                                }
                            }
                            .onTapGesture {
                                isFind.toggle()
                            }
                    }
                    .background {
                        if isFind {
                            AsyncImage(url: URL(string: "https://i.pinimg.com/564x/6a/4f/45/6a4f45fc425ea299727b0a16d07da75e.jpg")) { image in
                                image
                                    .resizable()
                                    .frame(width: 226, height: 226)
                                    .clipShape(Circle())
                            }
                            placeholder: {
                                ProgressView()
                            }
                        }
                    }
                    .padding(.bottom, 20)
                
                Text(isFind ? "Under The Influence" : "Listening ...")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(.black)
                
                Text("Chris Brown")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(isFind ? .gray.opacity(0.5) : .white)
                    .padding(.top, 4)
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
