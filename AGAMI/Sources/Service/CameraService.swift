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
    var videoDeviceInput: AVCaptureDeviceInput?
    var videoDevicePhotoSetting: AVCapturePhotoSettings?
    let output = AVCapturePhotoOutput()
    
    func setUpCamera() {
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            do {
                videoDeviceInput = try AVCaptureDeviceInput(device: device)
                
                guard let videoInput = videoDeviceInput else { return }
                
                if session.canAddInput(videoInput) {
                    session.addInput(videoInput)
                } else {
                    print("비디오 입력 에러")
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
    
    func changeCamera() {
        guard let currentPosition = videoDeviceInput else { return }
        
        let newPosition: AVCaptureDevice.Position = currentPosition.device.position == .front ? .back : .front
        
        guard let newDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: newPosition) else { return }
        
        do {
            // 새로운 입력 장치로 설정
            let newVideoDeviceInput = try AVCaptureDeviceInput(device: newDevice)
            session.beginConfiguration()
            
            // 현재 입력 장치 제거
            session.removeInput(currentPosition)
            
            // 새로운 입력 장치 추가
            if session.canAddInput(newVideoDeviceInput) {
                session.addInput(newVideoDeviceInput)
                videoDeviceInput = newVideoDeviceInput // videoDeviceInput 업데이트
            }
            
            session.commitConfiguration()
        } catch {
            print("카메라 전환 실패: \(error.localizedDescription)")
        }
    }
    
    func zoom(_ zoom: CGFloat){
        let factor = zoom < 1 ? 1 : zoom
        
        guard let device = self.videoDeviceInput?.device else { return }
        
        do {
            try device.lockForConfiguration()
            device.videoZoomFactor = factor
            device.unlockForConfiguration()
        }
        catch {
            print(error.localizedDescription)
        }
    }
}
