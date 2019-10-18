//
//  LocationService.swift
//
//  Created by Subhadeep Pal on 16/01/19.
//  Copyright © 2019 Subhadeep. All rights reserved.
//

import Foundation
import CoreLocation

protocol LocationDelegate {
    func locationUpdated(coordinate: CLLocationCoordinate2D)
}


final class LocationService: NSObject, CLLocationManagerDelegate {
    
    
    static var shared = LocationService()
    
    private let locationManager = CLLocationManager()
    private var delegatesSet: Set<AnyHashable> = []
    private var delegates: [LocationDelegate] {
        return delegatesSet.compactMap { $0 as? LocationDelegate }
    }
    private var lastKnownLocation: CLLocationCoordinate2D? {
        didSet {
            if let location = self.lastKnownLocation {
                MoEngage.sharedInstance().setUserLocationLatitude(location.latitude, andLongitude: location.longitude)
            }
        }
    }
    var lastKnownCoordinate: CLLocationCoordinate2D {
        if let lastKnownLocation_ = lastKnownLocation {
            return lastKnownLocation_
        } else {
            return CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        }
    }
    
    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter =  10.0 //kCLDistanceFilterNone
        locationManager.pausesLocationUpdatesAutomatically = false
    }
    
    func startUpdating() {
        locationManager.startUpdatingLocation()
    }
    
    func endUpdating() {
        locationManager.stopUpdatingLocation()
    }
    
    func add<O>(_ observer: O) where O : LocationDelegate, O : Hashable {
        let _ = delegatesSet.insert(observer)
        if let coordinate = self.lastKnownLocation {
            observer.locationUpdated(coordinate: coordinate)
        }
    }
    
    func remove<O>(_ observer: O) where O : LocationDelegate, O : Hashable {
        delegatesSet.remove(observer)
    }
    
    func requestAuthorization() {
        locationManager.requestAlwaysAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            self.requestAuthorization()
        case .restricted:
            self.requestAuthorization()
        case .denied:
            self.requestAuthorization()
        case .authorizedAlways:
            self.startUpdating()
        case .authorizedWhenInUse:
            self.startUpdating()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let mostRecentLocation = locations.last else { return }
        self.lastKnownLocation = mostRecentLocation.coordinate
        postLocationUpdate(coordinate: mostRecentLocation.coordinate)
    }
    
    private func postLocationUpdate(coordinate: CLLocationCoordinate2D) {
        for delegate in delegates {
            delegate.locationUpdated(coordinate: coordinate)
        }
    }
    
}
