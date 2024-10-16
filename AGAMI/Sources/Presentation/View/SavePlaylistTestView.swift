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
        
        let dummySongs: [Song] = [
            Song(songID: "1", title: "Song 1", artist: ["Artist 1"], albumCoverURL: "https://example.com/song1.jpg"),
            Song(songID: "2", title: "Song 2", artist: ["Artist 2"], albumCoverURL: "https://example.com/song2.jpg"),
            Song(songID: "3", title: "Song 3", artist: ["Artist 3"], albumCoverURL: "https://example.com/song3.jpg")
        ]
        
        let newPlaylist = Playlist(
            playlistName: playlistName,
            description: description,
            photoURL: photoURL,
            latitude: latitude,
            longitude: longitude,
            songs: dummySongs
        )
        
        do {
            try await firebaseService.savePlaylistToFirebase(userID: userID, playlist: newPlaylist)
        } catch {
            dump("플레이 리스트 저장 중 에러")
        }
        
        feedbackMessage = "Playlist saved successfully!"
    }
}

#Preview {
    SavePlaylistTestView()
}
