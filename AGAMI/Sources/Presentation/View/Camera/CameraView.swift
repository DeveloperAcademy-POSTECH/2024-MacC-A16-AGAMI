//
//  CameraView.swift
//  AGAMI
//
//  Created by yegang on 10/19/24.
//

import SwiftUI
import AVFoundation
import UIKit

struct CameraView: View {
    @Environment(SearchCoordinator.self) private var coordinator
    @State var viewModel = CameraViewModel()
    var searchWritingViewModel: SearchWritingViewModel
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                Spacer()
                
                if viewModel.isPhotoCaptured, let recentImage = viewModel.photoUIImage {
                    Image(uiImage: recentImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 400)
                        .cornerRadius(10)
                        .clipped()
                } else {
                    viewModel.cameraPreView
                        .frame(height: 400)
                        .onAppear {
                            viewModel.configure()
                        }
                        .gesture(MagnificationGesture()
                            .onChanged { val in
                                viewModel.zoom(factor: val)
                            }
                            .onEnded { _ in
                                viewModel.zoomInitialize()
                            })
                }
                
                HStack(spacing: 44) {
                    if !viewModel.isPhotoCaptured {
                        switchFlashButton
                        captureButton
                        changeCameraButton
                    } else {
                        resetPhotoButton
                        usedPhotoButton
                        savePhotoButton
                    }
                }
                .padding(EdgeInsets(top: 87, leading: 54, bottom: 113, trailing: 54))
            }
        }
        .toolbar(.hidden, for: .tabBar)
    }
    
    var captureButton: some View {
        Button {
            viewModel.capturePhoto()
        } label: {
            Circle()
                .foregroundColor(.white)
                .frame(width: 85, height: 85, alignment: .center)
                .overlay(
                    Circle()
                        .stroke(Color.black.opacity(0.8), lineWidth: 3)
                        .frame(width: 72.5, height: 72.5, alignment: .center)
                )
        }
    }
    
    var resetPhotoButton: some View {
        Button {
            viewModel.resetPhoto()
        } label: {
            Circle()
                .foregroundColor(Color.gray.opacity(0.2))
                .frame(width: 56, height: 56, alignment: .center)
                .overlay(
                    Image(systemName: "multiply")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.white))
        }
    }
    
    var usedPhotoButton: some View {
        Button {
            if let croppedImage = viewModel.photoUIImage?.cropSquare() {
                searchWritingViewModel.savePhotoUIImage(photoUIImage: croppedImage)
            }
            coordinator.pop()
        } label: {
            Image(.cameraButton)
                .resizable()
                .frame(width: 85, height: 85, alignment: .center)
        }
    }
    
    var switchFlashButton: some View {
        Button {
            viewModel.switchFlash()
        } label: {
            Circle()
                .foregroundColor(.gray.opacity(0.2))
                .frame(width: 56, height: 56, alignment: .center)
                .overlay(
                    Image(systemName: viewModel.isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                        .font(.system(size: 26, weight: .medium))
                )
                .accentColor(viewModel.isFlashOn ? .yellow : .white)
        }
    }
    
    var savePhotoButton: some View {
        Button {
            viewModel.savePhoto()
        } label: {
            Circle()
                .foregroundColor(Color.gray.opacity(0.2))
                .frame(width: 56, height: 56, alignment: .center)
                .overlay(
                    Image(systemName: "square.and.arrow.down.fill")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.bottom, 4)
                )
        }
    }
    
    var changeCameraButton: some View {
        Button {
            viewModel.changeCamera()
        } label: {
            Circle()
                .foregroundColor(.gray.opacity(0.2))
                .frame(width: 56, height: 56, alignment: .center)
                .overlay(
                    Image(systemName: "camera.rotate.fill")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.white))
        }
    }
}

#Preview {
    CameraView(searchWritingViewModel: SearchWritingViewModel())
        .environment(SearchCoordinator())
}
