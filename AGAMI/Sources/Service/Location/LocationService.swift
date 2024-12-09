//
//  MapService.swift
//  AGAMI
//
//  Created by yegang on 10/13/24.
//

import Foundation
import CoreLocation

final class LocationService: NSObject {
    private var currentLocation: CLLocation?
    private var locationManager: CLLocationManager
    private var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var streetAddress: String?
    var locality: String?
    var region: String?
    var placeHolderAddress: String?

    static let shared = LocationService()

    private var locationContinuation: CheckedContinuation<CLLocationCoordinate2D, Error>?

    private override init() {
        locationManager = CLLocationManager()
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func requestLocationAuthorization() {
        let status = locationManager.authorizationStatus

        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied, .authorizedAlways, .authorizedWhenInUse:
            return
        @unknown default:
            return
        }
    }

    func requestCurrentLocation() async throws -> CLLocationCoordinate2D {
        return try await withCheckedThrowingContinuation { continuation in
            self.locationContinuation = continuation
            self.requestLocationAuthorization()
            self.locationManager.requestLocation()
        }
    }

    func coordinateToStreetAddress() async -> String? {
        guard let currentLocation else { return nil }
        return await withCheckedContinuation { continuation in
            let geocoder = CLGeocoder()
            let locale = Locale(identifier: "ko_KR")

            geocoder.reverseGeocodeLocation(currentLocation, preferredLocale: locale) { [weak self] placemarks, _ in
                guard let self = self else { return }
                if let address = placemarks?.last {
                    var currentAddress = ""

                    if let name = address.name {
                        currentAddress += name
                        self.placeHolderAddress = name
                        self.region = name
                    }

                    if let area = address.locality {
                        currentAddress += ", \(area)"
                        self.locality = area
                    }

                    self.streetAddress = currentAddress
                    continuation.resume(returning: currentAddress)
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location
        locationContinuation?.resume(returning: location.coordinate)
        locationContinuation = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        dump("위치 정보 가져오기 실패: \(error.localizedDescription)")
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus

        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            dump("위치 서비스 권한이 허용되었습니다.")
            manager.requestLocation()
        case .denied, .restricted:
            dump("위치 서비스 권한이 거부되었습니다.")
            manager.requestWhenInUseAuthorization()
        case .notDetermined:
            dump("위치 서비스 권한이 결정되지 않았습니다.")
            manager.requestWhenInUseAuthorization()
        @unknown default:
            break
        }
    }
}
