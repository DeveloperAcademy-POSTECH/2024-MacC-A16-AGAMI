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
                        Task {
                            await viewModel.createPlaylist()
                        }
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

                    TextField("곡 제목 입력", text: $viewModel.songTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    Button {
                        Task {
                            await viewModel.searchAndAddSong()
                        }
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
            Task {
                do {
                    try await viewModel.requestAuthorization()
                } catch {
                    viewModel.statusMessage = "음악 라이브러리 접근 권한이 필요합니다."
                }
            }
        }
    }
}

#Preview {
    MusicKitPlaylistView()
}
