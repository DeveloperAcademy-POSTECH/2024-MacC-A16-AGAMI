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

@Observable
final class MusicViewModel {
    var playlistName: String = ""
    var playlistDescription: String = ""
    var songTitle: String = ""
    var statusMessage: String = ""

    @ObservationIgnored private var playlist: Playlist?

    func requestAuthorization() async throws {
        let status = MusicAuthorization.currentStatus
        switch status {
        case .authorized:
            break
        case .notDetermined:
            let newStatus = await MusicAuthorization.request()
            if newStatus != .authorized {
                throw MusicAuthorizationError.denied
            }
        default:
            throw MusicAuthorizationError.denied
        }
    }

    func createPlaylist() async {
        do {
            try await requestAuthorization()

            let library = MusicLibrary.shared
            playlist = try await library.createPlaylist(name: playlistName, description: playlistDescription)

            statusMessage = "플레이리스트 '\(playlistName)' 생성 완료."
        } catch {
            statusMessage = "플레이리스트 생성 오류: \(error.localizedDescription)"
        }
    }

    func searchAndAddSong() async {
        do {
            try await requestAuthorization()

            guard let playlist = playlist else {
                statusMessage = "먼저 플레이리스트를 생성해주세요."
                return
            }

            var searchRequest = MusicCatalogSearchRequest(term: songTitle, types: [Song.self])

            searchRequest.limit = 1
            let searchResponse = try await searchRequest.response()

            if let song = searchResponse.songs.first {
                try await MusicLibrary.shared.add(song, to: playlist)
                statusMessage = "'\(song.title)' 곡이 플레이리스트에 추가되었습니다."
            } else {
                statusMessage = "곡을 찾을 수 없습니다."
            }
        } catch {
            statusMessage = "곡 추가 오류: \(error.localizedDescription)"
        }
    }
}

enum MusicAuthorizationError: Error {
    case denied
}

#Preview {
    MusicKitPlaylistView()
}
