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
                viewModel.cameraPrewView
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
            //TODO: - 사진 찍는 버튼
            
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
            //TODO: - 누르면 사진 다시 찍게하기
            
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
            //TODO: - 찍은 사진사용 버튼
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
            //TODO: - 플래시 모드 on/off
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
            //TODO: - 누르면 사진 저장되게 맹들기
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
            //TODO: - 카메라 전/후면 돌리기
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
