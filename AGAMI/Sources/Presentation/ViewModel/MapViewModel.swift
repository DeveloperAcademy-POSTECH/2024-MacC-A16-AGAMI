//
//  MapViewModel.swift
//  AGAMI
//
//  Created by yegang on 10/12/24.
//

import Foundation
import MapKit

struct Place: Identifiable {
    var id: UUID = UUID()
    var location: CLLocationCoordinate2D
}

@Observable
final class MapViewModel: NSObject, CLLocationManagerDelegate {
    static let mapServie = MapViewModel()
    private var mapSeriveManger: CLLocationManager = CLLocationManager()
    
    override init() {
        super.init()
        self.mapSeriveManger.delegate = self
        mapSeriveManger.desiredAccuracy = kCLLocationAccuracyBest
        
        if self.mapSeriveManger.authorizationStatus == .notDetermined {
            self.mapSeriveManger.requestWhenInUseAuthorization()
        }
    }
    
    var currentLocation: CLLocationCoordinate2D?
    var places: [Place] = [
        Place(location: CLLocationCoordinate2D(latitude: 36.114332, longitude: 129.425743)),
        Place(location: CLLocationCoordinate2D(latitude: 36.214332, longitude: 129.525743))
    ]
    
    func getCurrentLocation() {
        if self.mapSeriveManger.authorizationStatus == .authorizedWhenInUse || self.mapSeriveManger.authorizationStatus == .authorizedAlways {
            self.mapSeriveManger.requestLocation()
        } else {
            self.mapSeriveManger.requestWhenInUseAuthorization()
        }
    }
    
    func addCurrentLocation() {
        if let currentLocation = currentLocation {
            let newPlace = Place(location: currentLocation)
            places.append(newPlace)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            currentLocation = location.coordinate
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user's location: \(error.localizedDescription)")
    }
}

