//
//  FireabaseTestView.swift
//  AGAMI
//
//  Created by taehun on 10/14/24.
//
import SwiftUI
import Firebase

struct SavePlaylistTestView: View {
    private var firebaseService = FirebaseService()
    @State private var userID: String = ""
    @State private var playlistName: String = ""
    @State private var description: String = ""
    @State private var photoURL: String = ""
    @State private var latitude: String = "36.0126"
    @State private var longitude: String = "129.3235"
    @State private var feedbackMessage: String = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Save Playlist to Firestore")
                .font(.title)
                .padding()

            TextField("Enter User ID", text: $userID)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            TextField("Playlist Name", text: $playlistName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            TextField("Description", text: $description)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            TextField("Photo URL", text: $photoURL)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            TextField("Latitude", text: $latitude)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)
                .padding()

            TextField("Longitude", text: $longitude)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)
                .padding()

            Button {
                Task {
                    await savePlaylist()
                }
            } label: {
                Text("Save Playlist")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 200, height: 50)
                    .background(Color.blue)
                    .cornerRadius(10)
            }

            Text(feedbackMessage)
                .foregroundColor(.red)
                .padding()

            Spacer()
        }
        .padding()
        .onAppear {
            if let uid = FirebaseAuthService.currentUID {
                userID = uid
            }
        }
    }

    func savePlaylist() async {
        guard !userID.isEmpty, !playlistName.isEmpty, !latitude.isEmpty, !longitude.isEmpty else {
            feedbackMessage = "Please fill in all fields."
            return
        }

        guard let latitude = Double(latitude), let longitude = Double(longitude) else {
            feedbackMessage = "Invalid latitude or longitude."
            return
        }

        let dummySongs: [SongModel] =
        (1...3).map { index in
            FirestoreSongModel(
                songID: "\(index)",
                title: "Song \(index)",
                artist: "Artist \(index)",
                albumCoverURL: "https://example.com/song\(index).jpg"
            )
        }

        let newPlaylist: PlaylistModel = FirestorePlaylistModel(
            playlistName: playlistName,
            playlistDescription: description,
            photoURL: photoURL,
            latitude: latitude,
            longitude: longitude,
            firestoreSongs: dummySongs.map { FirestoreSongModel(from: $0) }
        )

        do {
            try await firebaseService.savePlaylistToFirebase(userID: userID, playlist: FirestorePlaylistModel(from: newPlaylist))
        } catch {
            dump("플레이 리스트 저장 중 에러")
        }

        feedbackMessage = "Playlist saved successfully!"
    }
}

#Preview {
    SavePlaylistTestView()
}
