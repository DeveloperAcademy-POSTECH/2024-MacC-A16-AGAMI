//
//  FirebaseTestView2.swift
//  AGAMI
//
//  Created by taehun on 10/14/24.
//

import SwiftUI

struct FetchPlaylistsTestView: View {
    var firebaseService = FirebaseService()
    @State private var userID: String = ""
    @State private var playlists: [PlaylistModel] = []
    @State private var errorMessage: String = ""
    @State private var isLoading: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Fetch Playlists by User ID")
                .font(.title)
                .padding()
            
            TextField("Enter User ID", text: $userID)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button {
                Task {
                    await fetchPlaylists()
                }
            } label: {
                Text("Fetch Playlists")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 200, height: 50)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            
            if isLoading {
                ProgressView("Loading Playlists...")
                    .padding()
            }
            
            if !playlists.isEmpty {
                List(playlists, id: \.playlistID) { playlist in
                    VStack(alignment: .leading) {
                        Text("Playlist Name: \(playlist.playlistName)")
                            .font(.headline)
                        Text("Description: \(playlist.description)")
                        Text("Latitude: \(playlist.latitude)")
                        Text("Longitude: \(playlist.longitude)")
                        Text("Generation Time: \(playlist.generationTime, style: .date)")
                        
                        ForEach(playlist.songs, id: \.songID) { song in
                            Text("Song: \(song.title) by \(song.artist.joined(separator: ", "))")
                        }
                    }
                    .padding(.vertical, 10)
                }
            }
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
            
            Spacer()
        }
        .padding()
    }
    
    func fetchPlaylists() async {
        guard !userID.isEmpty else {
            errorMessage = "Please enter a valid User ID."
            return
        }
        
        isLoading = true
        
        do {
            let fetchedPlaylists = try await firebaseService.fetchPlaylistsByUserID(userID: userID)
            self.playlists = fetchedPlaylists
            self.errorMessage = ""
        } catch {
            self.errorMessage = "Error fetching playlists: \(error.localizedDescription)"
            self.playlists = []
        }
        
        isLoading = false
    }
    
}

#Preview {
    FetchPlaylistsTestView()
}
