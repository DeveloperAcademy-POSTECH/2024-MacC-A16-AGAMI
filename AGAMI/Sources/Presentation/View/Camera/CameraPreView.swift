//
//  CameraPreView.swift
//  AGAMI
//
//  Created by yegang on 10/19/24.
//

import SwiftUI
import AVFoundation

struct CameraPreview: UIViewRepresentable {
    class VideoPreviewView: UIView {
        override class var layerClass: AnyClass {
             AVCaptureVideoPreviewLayer.self
        }
        
        var videoPreviewLayer: AVCaptureVideoPreviewLayer {
            guard let previewLayer = layer as? AVCaptureVideoPreviewLayer
            else {
                fatalError("Expected AVCaptureVideoPreviewLayer but found \(type(of: layer))")
            }
            return previewLayer
        }
    }
    
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> VideoPreviewView {
        let view = VideoPreviewView()
        
        view.backgroundColor = .white // 기본 백그라운드 색 지정
        view.videoPreviewLayer.videoGravity = .resizeAspectFill // 카메라 프리뷰 ratio 조절(fit, fill)
        view.videoPreviewLayer.cornerRadius = 10 // 프리뷰 모서리에 CornerRadius를 결정
        view.videoPreviewLayer.session = session // 카메라 세션 지정(필수)

        return view
    }
    
    func updateUIView(_ uiView: VideoPreviewView, context: Context) { }
}
