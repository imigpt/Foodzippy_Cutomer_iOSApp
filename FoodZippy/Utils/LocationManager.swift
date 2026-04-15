// LocationManager.swift
// Replaces Android FusedLocationProviderClient

import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    
    private let manager = CLLocationManager()
    
    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var currentAddress: String = ""
    @Published var isAuthorized = false
    
    var latitude: String {
        String(currentLocation?.coordinate.latitude ?? 0)
    }
    
    var longitude: String {
        String(currentLocation?.coordinate.longitude ?? 0)
    }
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 50
        authorizationStatus = manager.authorizationStatus
        updateAuthStatus()
    }
    
    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }
    
    func startUpdating() {
        manager.startUpdatingLocation()
    }
    
    func stopUpdating() {
        manager.stopUpdatingLocation()
    }
    
    func requestCurrentLocation() {
        if isAuthorized {
            manager.requestLocation()
        } else {
            requestPermission()
        }
    }
    
    // MARK: - Reverse Geocode
    
    func reverseGeocode(latitude: Double, longitude: Double) async -> String {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            if let placemark = placemarks.first {
                var parts: [String] = []
                if let name = placemark.name { parts.append(name) }
                if let locality = placemark.locality { parts.append(locality) }
                if let subLocality = placemark.subLocality { parts.append(subLocality) }
                if let adminArea = placemark.administrativeArea { parts.append(adminArea) }
                if let postalCode = placemark.postalCode { parts.append(postalCode) }
                return parts.joined(separator: ", ")
            }
        } catch {
            print("Geocoding error: \(error)")
        }
        return ""
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location
        
        Task {
            let address = await reverseGeocode(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )
            await MainActor.run {
                self.currentAddress = address
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        updateAuthStatus()
        
        if isAuthorized {
            manager.startUpdatingLocation()
        }
    }
    
    private func updateAuthStatus() {
        switch authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            isAuthorized = true
        default:
            isAuthorized = false
        }
    }
    
    // MARK: - Distance Calculation
    
    func distance(toLat: Double, toLng: Double) -> Double {
        guard let current = currentLocation else { return 0 }
        let destination = CLLocation(latitude: toLat, longitude: toLng)
        return current.distance(from: destination) / 1000 // km
    }
}
