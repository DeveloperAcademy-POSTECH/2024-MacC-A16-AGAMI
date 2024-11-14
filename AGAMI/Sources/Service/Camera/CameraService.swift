//
//  CameraService.swift
//  AGAMI
//
//  Created by yegang on 10/19/24.
//

import Foundation
import AVFoundation
import UIKit

final class CameraService: NSObject {
    let session = AVCaptureSession()
    private var videoDeviceInput: AVCaptureDeviceInput?
    private let output = AVCapturePhotoOutput()
    private var lastScale: CGFloat = 1.0

    private var currentCameraPosition: AVCaptureDevice.Position = .back
    var onPhotoCaptured: ((Data) -> Void)?

    func setUpCamera() {
        if let currentInput = videoDeviceInput {
            session.removeInput(currentInput)
        }
        
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            do {
                videoDeviceInput = try AVCaptureDeviceInput(device: device)
                
                guard let videoInput = videoDeviceInput else { return }
                
                if session.canAddInput(videoInput) {
                    session.addInput(videoInput)
                } else {
                    dump("비디오 입력 에러")
                }
                
                if session.canAddOutput(output) {
                    session.addOutput(output)
                    
                    if let supportedFormat = device.activeFormat.supportedMaxPhotoDimensions.first {
                        output.maxPhotoDimensions = supportedFormat
                    } else {
                        dump("지원되는 해상도를 찾을 수 없음")
                    }
                    output.maxPhotoQualityPrioritization = .quality
                }
                
                DispatchQueue.global(qos: .userInitiated).async {
                    self.session.startRunning()
                }
            } catch {
                dump("카메라 셋업 실패")
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
            dump("권한 확인 실패")
        }
    }
    
    func capturePhoto(withFlash isOn: Bool) {
        let photoSettings = AVCapturePhotoSettings()
        photoSettings.flashMode = isOn ? .on : .off
        output.capturePhoto(with: photoSettings, delegate: self)
    }
    
    func savePhoto(_ imageData: Data) {
        guard let image = UIImage(data: imageData) else { return }
                
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        dump("사진 저장")
    }
    
    func changeCamera() {
        guard let currentPosition = videoDeviceInput else { return }
        
        let newPosition: AVCaptureDevice.Position = currentPosition.device.position == .front ? .back : .front
        
        guard let newDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: newPosition) else { return }
        
        do {
            let newVideoDeviceInput = try AVCaptureDeviceInput(device: newDevice)
            session.beginConfiguration()
            session.removeInput(currentPosition)
            
            if session.canAddInput(newVideoDeviceInput) {
                session.addInput(newVideoDeviceInput)
                videoDeviceInput = newVideoDeviceInput // videoDeviceInput 업데이트
                
                currentCameraPosition = newPosition
            }
            
            session.commitConfiguration()
        } catch {
            dump("카메라 전환 실패: \(error.localizedDescription)")
        }
    }
    
    func zoom(_ zoom: CGFloat) {
        let factor = zoom < 1 ? 1 : zoom
        
        guard let device = self.videoDeviceInput?.device else { return }
        
        do {
            try device.lockForConfiguration()
            device.videoZoomFactor = factor
            device.unlockForConfiguration()
        } catch {
            dump(error.localizedDescription)
        }
    }
}

extension CameraService: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, willBeginCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings) { }
    
    func photoOutput(_ output: AVCapturePhotoOutput, willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        // 카메라 무음
        AudioServicesDisposeSystemSoundID(1108)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        // 카메라 무음
        AudioServicesDisposeSystemSoundID(1108)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        // 카메라 좌우반전 아직 미구현
        guard let imageData = photo.fileDataRepresentation() else { return }
        
        var capturedImage = UIImage(data: imageData)
        
        if currentCameraPosition == .front {
            capturedImage = capturedImage?.withHorizontallyFlippedOrientation()
        }
        
        onPhotoCaptured?(imageData)
    }
}
