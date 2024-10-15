//
//  ImageUploadTestView.swift
//  AGAMI
//
//  Created by taehun on 10/15/24.
//

import SwiftUI
import PhotosUI

struct UploadImageTestView: View {
    @StateObject private var firebaseService = FirebaseService()
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImage: UIImage? = nil
    @State private var isUploading = false
    @State private var uploadResultMessage: String = ""
    
    private let userID = "123456"
    private let playlistID = "08AEDA20-460A-403C-A04A-A411F6109DFC"
    
    var body: some View {
        VStack {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
            } else {
                Rectangle()
                    .fill(Color.gray)
                    .frame(height: 200)
                    .overlay(
                        Text("Select an image")
                            .foregroundColor(.white)
                    )
            }
            
            PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                Text("Choose Image")
            }
            .onChange(of: selectedItem) { newItem in
                Task {
                    if let newItem = newItem {
                        if let data = try? await newItem.loadTransferable(type: Data.self),
                           let image = UIImage(data: data) {
                            selectedImage = image
                        }
                    }
                }
            }
            .padding()
            
            Button("Upload Image") {
                if let image = selectedImage {
                    uploadImage(image: image)
                } else {
                    uploadResultMessage = "No image selected."
                }
            }
            .disabled(selectedImage == nil || isUploading)
            .padding()
            
            Text(uploadResultMessage)
                .padding()
        }
        .padding()
    }
    
    private func uploadImage(image: UIImage) {
        isUploading = true
        uploadResultMessage = "Uploading..."
        
        firebaseService.uploadImageToFirebase(userID: userID, playlistID: playlistID, image: image) { result in
            DispatchQueue.main.async {
                self.isUploading = false
                switch result {
                case .success:
                    self.uploadResultMessage = "Image uploaded and photoURL updated successfully!"
                case .failure(let error):
                    self.uploadResultMessage = "Error: \(error.localizedDescription)"
                }
            }
        }
    }
}

#Preview {
    UploadImageTestView()
}
