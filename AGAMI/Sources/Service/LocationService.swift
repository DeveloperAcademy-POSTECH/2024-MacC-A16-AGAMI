//
//  MapService.swift
//  AGAMI
//
//  Created by yegang on 10/13/24.
//

import Foundation
import CoreLocation

protocol LocationServiceDelegate: AnyObject {
    func locationService(_ service: LocationService, didUpdate location: [CLLocation])
    func locationService(_ service: LocationService, didGetReverseGeocode location: String)
}

final class LocationService: NSObject {
    private var currentLocation: CLLocation?
    private var locationManager: CLLocationManager = CLLocationManager()
    private var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var streetAddress: String?
    var locality: String?
    var region: String?
    var placeHolderAddress: String?
    
    static let shared = LocationService()
    
    weak var delegate: LocationServiceDelegate?
    
    private override init() {
            locationManager = CLLocationManager()
            super.init()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
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
    
    func requestCurrentLocation() {
        dump("service currentLocation")
        let status = self.locationManager.authorizationStatus
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            self.locationManager.requestLocation()
        default:
            self.locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func getCurrentLocation() -> CLLocation? {
        currentLocation
    }
    
    func coordinateToStreetAddress(completion: @escaping (String?) -> Void) {
        guard let currentLocation else { return }
        
        let geocoder = CLGeocoder()
        let locale = Locale(identifier: "ko_KR")
        
        geocoder.reverseGeocodeLocation(currentLocation, preferredLocale: locale, completionHandler: { [weak self] (placemarks, _) in
            if let self = self {
                if let address: [CLPlacemark] = placemarks {
                    var currentAddress: String = ""
                    
                    if let area: String = address.last?.locality {
                        currentAddress += area
                        locality = area
                    }
                    
                    if let name: String = address.last?.name {
                        currentAddress += "\(name)"
                        placeHolderAddress = name
                        region = name
                    }
                    
                    self.streetAddress = currentAddress
                    self.delegate?.locationService(self, didGetReverseGeocode: currentAddress)
                    dump("self.streetAddress = currentAddress")
                    completion(currentAddress)
                }
            }
        })
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            currentLocation = location
        }
        
        dump("CLLocationManagerDelegate method called")
        self.delegate?.locationService(self, didUpdate: locations)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        dump("위치 정보 가져오기 실패: \(error.localizedDescription)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            print("위치 서비스 권한이 허용되었습니다.")
            manager.requestLocation()
        case .denied, .restricted:
            print("위치 서비스 권한이 거부되었습니다.")
            manager.requestWhenInUseAuthorization()
        case .notDetermined:
            print("위치 서비스 권한이 결정되지 않았습니다.")
            manager.requestWhenInUseAuthorization()
        @unknown default:
            break
        }
    }
}
