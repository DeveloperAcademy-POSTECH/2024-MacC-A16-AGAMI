//
//  CameraViewModel.swift
//  AGAMI
//
//  Created by yegang on 10/19/24.
//

import SwiftUICore
import AVFoundation
import UIKit

@Observable
final class CameraViewModel: ObservableObject {
    private let cameraService: CameraService
    private let session: AVCaptureSession
    
    private var currentZoomFactor: CGFloat = 1.0
    private var lastScale: CGFloat = 1.0
    
    let cameraPreView: CameraPreview
    
    var recentImage: UIImage?
    var isPhotoCaptured: Bool = false
    var isFlashOn: Bool = false
    
    init() {
        cameraService = CameraService()
        session = cameraService.session
        cameraPreView = CameraPreview(session: session)
        
        cameraService.onPhotoCaptured = { [weak self] imageData in
            if let image = UIImage(data: imageData) {
                self?.recentImage = image
                self?.isPhotoCaptured = true
            }
        }
    }
    
    func configure() {
        cameraService.requestAndCheckPermission()
    }
    
    func capturePhoto() {
        cameraService.capturePhoto(withFlash: isFlashOn)
    }
    
    func resetPhoto() {
        isPhotoCaptured = false
        recentImage = nil
        
        cameraService.session.stopRunning()
        cameraService.setUpCamera()
    }
    
    func changeCamera() {
        cameraService.changeCamera()
    }
    
    func switchFlash() {
        isFlashOn.toggle()
    }
    
    func zoom(factor: CGFloat) {
        let delta = factor / lastScale
        lastScale = factor
        
        let newScale = min(max(currentZoomFactor * delta, 1), 5)
        cameraService.zoom(newScale)
        currentZoomFactor = newScale
    }
    
    func zoomInitialize() {
        lastScale = 1.0
    }
    
    func savePhoto() {
        guard let image = recentImage, let imageData = image.jpegData(compressionQuality: 1.0) else { return }
        cameraService.savePhoto(imageData)
    }
}
