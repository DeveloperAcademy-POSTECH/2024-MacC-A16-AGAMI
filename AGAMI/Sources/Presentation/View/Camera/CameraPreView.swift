//
//  CameraPreView.swift
//  AGAMI
//
//  Created by yegang on 10/19/24.
//

import SwiftUI
import AVFoundation

struct CameraPreview: UIViewRepresentable {
    let viewModel: CameraViewModel

    class VideoPreviewView: UIView {
        override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }

        var videoPreviewLayer: AVCaptureVideoPreviewLayer {
            guard let previewLayer = layer as? AVCaptureVideoPreviewLayer
            else { fatalError("Expected AVCaptureVideoPreviewLayer but found \(type(of: layer))") }
            return previewLayer
        }
    }

    func makeUIView(context: Context) -> VideoPreviewView {
        let view = VideoPreviewView()
        view.backgroundColor = .white
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        view.videoPreviewLayer.cornerRadius = 4
        view.videoPreviewLayer.session = viewModel.getSession()

        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleTap(_:)))
        view.addGestureRecognizer(tapGesture)

        return view
    }

    func updateUIView(_ uiView: VideoPreviewView, context: Context) { }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        let parent: CameraPreview

        init(_ parent: CameraPreview) {
            self.parent = parent
        }

        @objc func handleTap(_ sender: UITapGestureRecognizer) {
            let tapPoint = sender.location(in: sender.view)
            guard let previewView = sender.view else { return }
            parent.viewModel.setFocus(at: tapPoint, in: previewView)
        }
    }
}
