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
final class CameraViewModel {
    private let cameraService: CameraService = CameraService()
    private let firebaseService = FirebaseService()
    
    private var currentZoomFactor: CGFloat = 1.0
    private var lastScale: CGFloat = 1.0
    
    let cameraPreView: CameraPreview
    
    var photoUIImage: UIImage?
    var isPhotoCaptured: Bool = false
    var isFlashOn: Bool = false
    var photoURL: String?
    
    init() {
        cameraPreView = CameraPreview(session: cameraService.session)
        cameraService.onPhotoCaptured = { [weak self] imageData in
            if let image = UIImage(data: imageData) {
                self?.photoUIImage = image
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
        photoUIImage = nil
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
        guard let image = photoUIImage, let imageData = image.jpegData(compressionQuality: 1.0) else { return }
        cameraService.savePhoto(imageData)
    }
    
    func savePhotoToFirebase(userID: String) async -> String? {
        if let image = photoUIImage {
            do {
                photoURL = try await firebaseService.uploadImageToFirebase(userID: userID, image: image)
            } catch {
                print("이미지 저장 실패: \(error.localizedDescription)")
            }
        }
        return photoURL
    }
}
