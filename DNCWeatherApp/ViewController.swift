//
//  ViewController.swift
//  DNCWeatherApp
//
//  Created by Ilya Tovstokory on 05.10.2023.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    var currentResult: CurrentResult?
    var forecastResult: ForecastResult?
    let apiService = APIService.shared
    
    let locationManager = CLLocationManager()
    
    var currentLocation: CLLocation?
    
    var lat: String = ""
    var lon: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocation()
    }
    
    // MARK: - Fetching functions

    func fetchCurrentResult() {
        
        apiService.getJSON(urlString: "http://api.weatherapi.com/v1/current.json?q=\(lat),\(lon)") { (result: Result<CurrentResult, APIError>) in
            switch result {
            case .success(let currentResult):
                DispatchQueue.main.async {
                    self.currentResult = currentResult
                }
            case .failure(let error):
                #warning("Add error handling and remove print")
                print(error.localizedDescription)
            }
        }
    }
    
    func fetchForecastResult() {
        
        apiService.getJSON(urlString: "http://api.weatherapi.com/v1/forecast.json?q=\(lat),\(lon)&days=3") { (result: Result<ForecastResult, APIError>) in
            switch result {
            case .success(let forecastResult):
                DispatchQueue.main.async {
                    self.forecastResult = forecastResult
                }
            case .failure(let error):
                #warning("Add error handling and remove print")
                print(error.localizedDescription)
            }
        }
    }
}

// MARK: - Extension of VC for Location

extension ViewController: CLLocationManagerDelegate {
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
        
        fetchCurrentResult()
        fetchForecastResult()
    }
}
