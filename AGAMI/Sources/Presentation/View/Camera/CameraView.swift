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
    @Environment(PlakeCoordinator.self) private var coordinator
    @State private var viewModel = CameraViewModel()
    let viewModelContainer: CoordinatorViewModelContainer?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(.sBlack).edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    if viewModel.isPhotoCaptured, let recentImage = viewModel.photoUIImage {
                        Image(uiImage: recentImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width, height: geometry.size.width * 4 / 5)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                            .clipped()
                    } else {
                        viewModel.cameraPreView
                            .frame(width: geometry.size.width, height: geometry.size.width * 4 / 5)
                            .onAppear {
                                viewModel.configure()
                            }
                            .gesture(
                                MagnificationGesture()
                                    .onChanged { val in
                                        viewModel.zoom(factor: val)
                                    }
                                    .onEnded { _ in
                                        viewModel.zoomInitialize()
                                    }
                            )
                    }
                    
                    HStack(spacing: 44) {
                        if !viewModel.isPhotoCaptured {
                            switchFlashButton
                            captureButton
                            changeCameraButton
                        } else {
                            ZStack {
                                usedPhotoButton
                                
                                HStack(spacing: 0) {
                                    resetPhotoButton
                                    Spacer()
                                }
                            }
                        }
                    }
                    .padding(EdgeInsets(top: 87, leading: 54, bottom: 113, trailing: 54))
                }
            }
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    ToolbarLeadingItem(viewModel: viewModel)
                }
            }
            .disablePopGesture()
        }
    }
    
    private var captureButton: some View {
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
    
    private var resetPhotoButton: some View {
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
    
    private var usedPhotoButton: some View {
        Button {
            guard let croppedImage = viewModel.photoUIImage?.cropToFiveByFour() else { return }
            
            switch viewModelContainer {
            case let .searchWriting(viewModel):
                viewModel.savePhotoUIImage(photoUIImage: croppedImage)
            case let .plakePlaylist(viewModel):
                viewModel.setPhotoFromCamera(photo: croppedImage)
            case nil:
                return
            }
            coordinator.pop()
        } label: {
            Image(.cameraButton)
                .resizable()
                .frame(width: 85, height: 85, alignment: .center)
        }
    }
    
    private var switchFlashButton: some View {
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
    
    private var changeCameraButton: some View {
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

private struct ToolbarLeadingItem: View {
    @Environment(PlakeCoordinator.self) private var coordinator
    var viewModel: CameraViewModel
    
    var body: some View {
        Button {
            coordinator.pop()
        } label: {
            if !viewModel.isPhotoCaptured {
                Image(systemName: "chevron.backward")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(Color(.sMain))
                    .frame(width: 15, height: 22)
            }
        }
    }
}
