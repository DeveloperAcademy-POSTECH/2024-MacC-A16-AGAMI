//
//  CameraService.swift
//  AGAMI
//
//  Created by yegang on 10/19/24.
//

import Foundation
import AVFoundation

final class CameraService {
    var session = AVCaptureSession()
    var videoDeviceInput: AVCaptureDeviceInput!
    let output = AVCapturePhotoOutput()
    
    func setUpCamera() {
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            do {
                videoDeviceInput = try AVCaptureDeviceInput(device: device)
                if session.canAddInput(videoDeviceInput) {
                    session.addInput(videoDeviceInput)
                }
                
                if session.canAddOutput(output) {
                    session.addOutput(output)
                    
                    if let supportedFormat = device.activeFormat.supportedMaxPhotoDimensions.first {
                        output.maxPhotoDimensions = supportedFormat
                    } else {
                        print("지원되는 해상도를 찾을 수 없음")
                    }
                    output.maxPhotoQualityPrioritization = .quality
                }
                
                DispatchQueue.global(qos: .userInitiated).async {
                    self.session.startRunning()
                }
            } catch {
                print("카메라 셋업 실패")
            }
        }
    }
    
    func requestAndCheckPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] authStatus in
                if authStatus {
                    DispatchQueue.main.async {
                        self?.setUpCamera()
                    }
                }
            }
        case .restricted:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] authStatus in
                if authStatus {
                    DispatchQueue.main.async {
                        self?.setUpCamera()
                    }
                }
            }
        case .authorized:
            setUpCamera()
        default:
            print("권한 확인 실패")
        }
    }
}
