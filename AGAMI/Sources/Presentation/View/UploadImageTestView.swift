//
//  ImageUploadTestView.swift
//  AGAMI
//
//  Created by taehun on 10/15/24.
//

import SwiftUI
import PhotosUI

struct UploadImageTestView: View {
    private var firebaseService = FirebaseService()
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
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
            .onChange(of: selectedItem) { oldItem, newItem in
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
                    Task {
                        await uploadImage(image: image)
                    }
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
    
    func uploadImage(image: UIImage) async {
        isUploading = true
        uploadResultMessage = "Uploading..."
        
        do {
            try await firebaseService.uploadImageToFirebase(userID: userID, playlistID: playlistID, image: image)
            DispatchQueue.main.async {
                self.isUploading = false
                self.uploadResultMessage = "Image uploaded and photoURL updated successfully!"
            }
        } catch {
            DispatchQueue.main.async {
                self.isUploading = false
                self.uploadResultMessage = "Error: \(error.localizedDescription)"
            }
        }
    }
}

#Preview {
    UploadImageTestView()
}
