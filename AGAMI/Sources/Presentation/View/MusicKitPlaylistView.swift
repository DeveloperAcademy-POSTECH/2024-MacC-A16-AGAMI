//
//  MusicKitPlaylistView.swift
//  AGAMI
//
//  Created by 박현수 on 10/10/24.
//

import SwiftUI
import MusicKit

struct MusicKitPlaylistView: View {
    @State private var viewModel = MusicViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                
                VStack(alignment: .leading) {
                    Text("플레이리스트 생성")
                        .font(.headline)
                    
                    TextField("플레이리스트 이름", text: $viewModel.playlistName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("플레이리스트 설명", text: $viewModel.playlistDescription)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button {
                        viewModel.createPlaylist()
                    } label: {
                        Text("플레이리스트 생성")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                Divider()
                
                VStack(alignment: .leading) {
                    Text("곡 검색 및 추가")
                        .font(.headline)
                    
                    TextField("곡 아이디 입력", text: $viewModel.songId)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button {
                        viewModel.searchAndAddSong()
                    } label: {
                        Text("곡 추가")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                Spacer()
                
                Text(viewModel.statusMessage)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .navigationTitle("MusicKit 플레이리스트")
        }
        .onAppear {
            viewModel.requestAuthorization()
        }
    }
}

#Preview {
    MusicKitPlaylistView()
}
