//
//  CameraView.swift
//  AGAMI
//
//  Created by yegang on 10/19/24.
//

import SwiftUI
import AVFoundation

struct CameraView: View {
    @Environment(SearchCoordinator.self) var coordinator
    @State var viewModel = CameraViewModel()
    @State var isFlashOn = true
    @State var capturePhoto = true
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                if viewModel.isPhotoCaptured, let recentImage = viewModel.recentImage {
                    Image(uiImage: recentImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 400)
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
                            }
                        )
                }
                
                HStack {
                    captureButton
                    resetPhotoButton
                    switchFlashButton
                    usedPhotoButton
                    savePhotoButton
                    changeCameraButton
                }
            }
        }
    }
    
    var captureButton: some View {
        Button {
            viewModel.capturePhoto()
        } label: {
            Circle()
                .foregroundColor(.white)
                .frame(width: 80, height: 80, alignment: .center)
                .overlay(
                    Circle()
                        .stroke(Color.black.opacity(0.8), lineWidth: 2)
                        .frame(width: 65, height: 65, alignment: .center)
                )
        }
    }
    
    var resetPhotoButton: some View {
        Button {
            viewModel.resetPhoto()
        } label: {
            Circle()
                .foregroundColor(Color.gray.opacity(0.2))
                .frame(width: 45, height: 45, alignment: .center)
                .overlay(
                    Image(systemName: "multiply")
                        .foregroundColor(.white))
        }
    }
    
    var usedPhotoButton: some View {
        Button {
            //image 넘기기
            //넘길 이미지: viewModel.recentImage
            coordinator.pop()
        } label: {
            ZStack {
                Circle()
                    .foregroundColor(.red)
                    .frame(width: 80, height: 80, alignment: .center)
                
                Image(systemName: "checkmark")
                    .foregroundStyle(.white)
                    .font(.system(size: 25, weight: .bold, design: .default))
            }
            .overlay(
                Circle()
                    .stroke(Color.black.opacity(0.8), lineWidth: 2)
                    .frame(width: 65, height: 65, alignment: .center)
            )
        }
    }
    
    var switchFlashButton: some View {
        Button {
            viewModel.switchFlash()
        } label: {
            Circle()
                .foregroundColor(Color.gray.opacity(0.2))
                .frame(width: 45, height: 45, alignment: .center)
                .overlay(
                    Image(isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                        .font(.system(size: 20, weight: .medium, design: .default)))
        }
        .accentColor(isFlashOn ? .yellow : .white)
    }
    
    var savePhotoButton: some View {
        Button {
            viewModel.savePhoto()
        } label: {
            Circle()
                .foregroundColor(Color.gray.opacity(0.2))
                .frame(width: 45, height: 45, alignment: .center)
                .overlay(
                    Image(systemName: "square.and.arrow.down")
                        .foregroundColor(.white))
        }
    }
    
    var changeCameraButton: some View {
        Button {
            viewModel.changeCamera()
        } label: {
            Circle()
                .foregroundColor(Color.gray.opacity(0.2))
                .frame(width: 45, height: 45, alignment: .center)
                .overlay(
                    Image(systemName: "camera.rotate.fill")
                        .foregroundColor(.white))
        }
    }
}

#Preview {
    CameraView()
        .environment(SearchCoordinator())
}
