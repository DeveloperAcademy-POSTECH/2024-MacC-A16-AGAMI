//
//  CameraViewModel.swift
//  AGAMI
//
//  Created by yegang on 10/19/24.
//

import SwiftUICore
import AVFoundation

@Observable
final class CameraViewModel: ObservableObject {
    private let cameraService: CameraService
    private let session: AVCaptureSession
    
    let cameraPreView: CameraPreview
    
    init() {
        cameraService = CameraService()
        session = cameraService.session
        cameraPreView = CameraPreview(session: session)
    }
    
    func configure() {
        cameraService.requestAndCheckPermission()
    }
    
    func changeCamera() {
        cameraService.changeCamera()
    }
    
    func switchFlash() {
        
    }
}
