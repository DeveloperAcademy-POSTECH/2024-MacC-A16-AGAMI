//
//  CameraViewModel.swift
//  AGAMI
//
//  Created by yegang on 10/19/24.
//

import UIKit
import AVFoundation

@Observable
final class CameraViewModel {
    private let cameraService: CameraService = CameraService()
    private let firebaseService = FirebaseService()

    private var currentZoomFactor: CGFloat = 1.0
    private var lastScale: CGFloat = 1.0

    var viewModelContainer: CoordinatorViewModelContainer?
    var photoUIImage: UIImage?
    var isPhotoCaptured: Bool = false
    var isFlashOn: Bool = false
    var photoURL: String?

    init(container: CoordinatorViewModelContainer) {
        self.viewModelContainer = container
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

    func getSession() -> AVCaptureSession {
        cameraService.session
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

    func toggleCamera() {
        cameraService.toggleCamera()
    }

    func toggleFlash() {
        isFlashOn.toggle()
    }

    func savePhoto() {
        guard let croppedImage = photoUIImage?.cropToFiveByFour() else { return }

        switch viewModelContainer {
        case let .searchWriting(injectedViewModel):
            injectedViewModel.savePhotoUIImage(photoUIImage: croppedImage)
        case let .plakePlaylist(injectedViewModel):
            injectedViewModel.setPhotoFromCamera(photo: croppedImage)
        case nil:
            return
        }
    }

    func zoom(factor: CGFloat) {
        let delta = factor / lastScale
        lastScale = factor

        let newScale = min(max(currentZoomFactor * delta, 1), 5)
        cameraService.zoom(newScale)
        currentZoomFactor = newScale
    }

    func initializeZoom() {
        lastScale = 1.0
    }

    func setFocus(at point: CGPoint, in view: UIView) {
        cameraService.setFocus(at: point, in: view)
    }
}
