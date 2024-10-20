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
    
    init() {
        cameraService = CameraService()
        session = cameraService.session
        cameraPreView = CameraPreview(session: session)
    }
    
    func configure() {
        cameraService.requestAndCheckPermission()
    }
    
    func capturePhoto() {
        cameraService.capturePhoto()
    }
    
    func resetPhoto() {
        isPhotoCaptured = false
        recentImage = nil
    }
    
    func changeCamera() {
        cameraService.changeCamera()
    }
    
    func switchFlash() {
        
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
}
