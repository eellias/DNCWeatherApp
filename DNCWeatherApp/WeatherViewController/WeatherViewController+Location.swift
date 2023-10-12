//
//  WeatherViewController+Location.swift
//  DNCWeatherApp
//
//  Created by Ilya Tovstokory on 09.10.2023.
//

import Foundation
import CoreLocation

extension WeatherViewController: CLLocationManagerDelegate {
    func setupLocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !locations.isEmpty, currentLocation == nil {
            currentLocation = locations.first
            locationManager.stopUpdatingLocation()
            requestWeatherForLocation()
        }
    }
    
    func requestWeatherForLocation() {
        guard let currentLocation = currentLocation else { return }
        
        lon = String(currentLocation.coordinate.longitude)
        lat = String(currentLocation.coordinate.latitude)
        Task {
            await fetchForecastResult()
        }

    }
}
