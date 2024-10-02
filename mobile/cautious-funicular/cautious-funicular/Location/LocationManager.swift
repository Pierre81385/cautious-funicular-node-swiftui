//
//  LocationManager.swift
//  cautious-funicular
//
//  Created by m1_air on 9/22/24.
//

import SwiftUI
import CoreLocation
import Combine
import Observation

@Observable class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    var authorizationStatus: CLAuthorizationStatus?
    var currentLocation: CLLocation?
    var currentAddress: String = ""
    var errorMessage: String?
    
    private var geocoder = CLGeocoder()
    
    override init() {
        super.init()
        locationManager.delegate = self
        checkAuthorizationStatus()
    }
    
    // Check for location authorization
    func checkAuthorizationStatus() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            errorMessage = "Location access denied. Please enable location services."
        default:
            break
        }
    }
    
    // Start updating the location
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    // Stop updating the location
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    // Get current location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            self.currentLocation = location
            convertLocationToAddress(location: location)
        }
    }
    
    // Convert location to address
    func convertLocationToAddress(location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            if let error = error {
                self?.errorMessage = "Failed to get address: \(error.localizedDescription)"
                return
            }
            if let placemark = placemarks?.first {
                self?.currentAddress = [
                    placemark.name,
                    placemark.locality,
                    placemark.administrativeArea,
                    placemark.postalCode,
                    placemark.country
                ].compactMap { $0 }.joined(separator: ", ")
            }
        }
    }
    
    // Convert address to location
    func convertAddressToLocation(address: String, completion: @escaping (CLLocationCoordinate2D?, Error?) -> Void) {
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            if let location = placemarks?.first?.location {
                completion(location.coordinate, nil)
            } else {
                completion(nil, nil)
            }
        }
    }
    
    // Handle authorization status changes
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkAuthorizationStatus()
    }
    
    // Handle location manager errors
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        errorMessage = "Location update failed: \(error.localizedDescription)"
    }
}
