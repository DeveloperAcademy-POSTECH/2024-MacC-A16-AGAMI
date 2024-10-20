//
//  CameraView.swift
//  AGAMI
//
//  Created by yegang on 10/19/24.
//

import SwiftUI
import AVFoundation

struct CameraView: View {
    @State var viewModel = CameraViewModel()
    @State var isFlashOn = true
    @State var capturePhoto = true
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                viewModel.cameraPreView
                    .frame(height: 400)
                    .onAppear {
                        viewModel.configure()
                    }
                
                HStack {
                    captureButton
                    retryCaptureButton
                    switchFlashButton
                    usedPhotoButton
                    savePhotoButton
                    flipCameraButton
                }
                .border(.red)
            }
        }
    }
    
    var captureButton: some View {
        Button {
            
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
    
    var retryCaptureButton: some View {
        Button {
            
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

        } label: {
            Circle()
                .foregroundColor(Color.gray.opacity(0.2))
                .frame(width: 45, height: 45, alignment: .center)
                .overlay(
                    Image(systemName: "square.and.arrow.down")
                        .foregroundColor(.white))
        }
    }
    
    var flipCameraButton: some View {
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
}
