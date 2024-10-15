//
//  SwiftUIView.swift
//  AGAMI
//
//  Created by taehun on 10/15/24.
//

import SwiftUI
import Firebase

struct SaveImageToFirebaseTestView: View {
    @StateObject private var firebaseService = FirebaseService()
    @State private var userID = "123456"  // 테스트용 사용자 ID
    @State private var playlists: [PlaylistModel] = []
    @State private var image: UIImage?
    @State private var imageUrl: String?
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        VStack {
            Button(action: {
                firebaseService.fetchPlaylistsByUserID(userID: userID) { result in
                    switch result {
                    case .success(let fetchedPlaylists):
                        playlists = fetchedPlaylists
                    case .failure(let error):
                        alertMessage = "Error fetching playlists: \(error.localizedDescription)"
                        showAlert.toggle()
                    }
                }
            }) {
                Text("Fetch Playlists")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()

            List(playlists, id: \.playlistID) { playlist in
                Text(playlist.playlistName)
            }

            Button(action: {
                if let image = image {
                    firebaseService.saveImageToFirebaseStorage(image: image)  
                } else {
                    alertMessage = "Please select an image first."
                    showAlert.toggle()
                }
            }) {
                Text("Upload Image")
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()

            if let imageUrl = firebaseService.imageUrl {
                Text("Image URL: \(imageUrl)")
                    .padding()
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
}

#Preview {
    SaveImageToFirebaseTestView()
}
