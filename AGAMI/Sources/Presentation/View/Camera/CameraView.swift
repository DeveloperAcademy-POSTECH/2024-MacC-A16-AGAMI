//
//  CameraView.swift
//  AGAMI
//
//  Created by yegang on 10/19/24.
//

import SwiftUI

struct CameraView: View {
    @Environment(PlakeCoordinator.self) private var coordinator
    @State private var viewModel: CameraViewModel

    init(viewModel: CameraViewModel) {
        _viewModel = .init(wrappedValue: viewModel)
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Spacer()

                PhotoPreview(viewModel: viewModel, size: geometry.size)

                ConfigureButtons(viewModel: viewModel)
            }
            .ignoresSafeArea()
            .background(Color(.sBlack))
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    ToolbarLeadingItem(viewModel: viewModel)
                }
            }
            .disablePopGesture()
        }
    }
}

private struct PhotoPreview: View {
    let viewModel: CameraViewModel
    let size: CGSize

    var body: some View {
        if viewModel.isPhotoCaptured, let recentImage = viewModel.photoUIImage {
            Image(uiImage: recentImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size.width, height: size.width * 4 / 5)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .clipped()
        } else {
            CameraPreview(viewModel: viewModel)
                .frame(width: size.width, height: size.width * 4 / 5)
                .onAppear {
                    viewModel.configure()
                }
                .gesture(
                    MagnificationGesture()
                        .onChanged { val in
                            viewModel.zoom(factor: val)
                        }
                        .onEnded { _ in
                            viewModel.initializeZoom()
                        }
                )
        }
    }
}

private struct ConfigureButtons: View {
    let viewModel: CameraViewModel

    var body: some View {
        HStack(spacing: 44) {
            if !viewModel.isPhotoCaptured {
                ToggleFlashButton(viewModel: viewModel)
                CaptureButton(viewModel: viewModel)
                ToggleCameraButton(viewModel: viewModel)
            } else {
                ZStack {
                    SavePhotoButton(viewModel: viewModel)

                    HStack(spacing: 0) {
                        ResetPhotoButton(viewModel: viewModel)
                        Spacer()
                    }
                }
            }
        }
        .padding(EdgeInsets(top: 87, leading: 54, bottom: 113, trailing: 54))
    }
}

private struct ResetPhotoButton: View {
    let viewModel: CameraViewModel

    var body: some View {
        Button {
            viewModel.resetPhoto()
        } label: {
            Circle()
                .foregroundColor(Color(.sMainTab))
                .frame(width: 56, height: 56, alignment: .center)
                .overlay(
                    Image(systemName: "multiply")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(Color(.sWhite)))
        }
    }
}

private struct ToggleFlashButton: View {
    let viewModel: CameraViewModel
    var body: some View {
        Button {
            viewModel.toggleFlash()
        } label: {
            Circle()
                .foregroundColor(Color(.sMainTab))
                .frame(width: 56, height: 56, alignment: .center)
                .overlay(
                    Image(systemName: viewModel.isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                        .font(.system(size: 26, weight: .regular))
                )
                .accentColor(viewModel.isFlashOn ? Color(.sFlash) : Color(.sWhite))
        }
    }
}

private struct ToggleCameraButton: View {
    let viewModel: CameraViewModel

    var body: some View {
        Button {
            viewModel.toggleCamera()
        } label: {
            Circle()
                .foregroundColor(Color(.sMainTab))
                .frame(width: 56, height: 56, alignment: .center)
                .overlay(
                    Image(systemName: "camera.rotate.fill")
                        .font(.system(size: 24, weight: .regular))
                        .foregroundColor(Color(.sWhite)))
        }
    }
}

private struct CaptureButton: View {
    let viewModel: CameraViewModel

    var body: some View {
        Button {
            viewModel.capturePhoto()
        } label: {
            Circle()
                .foregroundColor(Color(.sMain))
                .frame(width: 85, height: 85, alignment: .center)
                .overlay(
                    Circle()
                        .stroke(Color(.sBlack), lineWidth: 3)
                        .frame(width: 72.5, height: 72.5, alignment: .center)
                )
        }
    }
}

private struct SavePhotoButton: View {
    @Environment(PlakeCoordinator.self) private var coordinator
    let viewModel: CameraViewModel

    var body: some View {
        Button {
            viewModel.savePhoto()
            coordinator.pop()
        } label: {
            Image(.cameraButton)
                .resizable()
                .frame(width: 85, height: 85, alignment: .center)
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
