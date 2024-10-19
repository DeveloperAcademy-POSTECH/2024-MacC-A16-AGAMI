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
    
    let cameraPrewView: AnyView
    
    init() {
        cameraService = CameraService()
        session = cameraService.session
        cameraPrewView = AnyView(CameraPreview(session: session))
    }
    
    func configure() {
        cameraService.requestAndCheckPermission()
    }
}
