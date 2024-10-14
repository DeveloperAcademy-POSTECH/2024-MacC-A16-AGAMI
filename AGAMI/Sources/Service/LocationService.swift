//
//  MapService.swift
//  AGAMI
//
//  Created by yegang on 10/13/24.
//

import Foundation
import MapKit
import CoreLocation

final class LocationService: NSObject {
    private var currentLocation: CLLocationCoordinate2D?
    private var locationManager: CLLocationManager = .init()
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        if self.locationManager.authorizationStatus == .notDetermined {
            self.locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func requestLocationAuthorization() throws {
        let status = CLLocationManager().authorizationStatus
        
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            return
        case .notDetermined:
            CLLocationManager().requestWhenInUseAuthorization()
        case .restricted:
            throw LocationAuthorizationError.restricted
        default:
            throw LocationAuthorizationError.denied
        }
    }
    
    func requestCurrentLocation() {
        if self.locationManager.authorizationStatus == .authorizedWhenInUse || self.locationManager.authorizationStatus == .authorizedAlways {
            self.locationManager.requestLocation()
        } else {
            self.locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func getCurrentLocation() -> CLLocationCoordinate2D? {
        return currentLocation
    }
    
}

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            currentLocation = location.coordinate
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        dump("Failed to get user's location: \(error.localizedDescription)")
    }
}

enum LocationAuthorizationError: Error {
    case restricted
    case denied
}
