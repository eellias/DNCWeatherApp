//
//  ViewController.swift
//  DNCWeatherApp
//
//  Created by Ilya Tovstokory on 05.10.2023.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {
    var currentResult: CurrentResult?
    var forecastResult: ForecastResult?
    let apiService = APIService.shared
    
    let locationManager = CLLocationManager()
    
    var currentLocation: CLLocation?
    
    var lat: String = ""
    var lon: String = ""
    
    var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchForecastResult()
        setupCollectionView()
    }
    
    func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBlue
        view.addSubview(collectionView)
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        collectionView.delegate = self
        collectionView.dataSource = self
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
        
        apiService.getJSON(urlString: "http://api.weatherapi.com/v1/forecast.json?q=Kharkiv&days=3") { [weak self] (result: Result<ForecastResult, APIError>) in
            switch result {
            case .success(let forecastResult):
                DispatchQueue.main.async {
                    self?.forecastResult = forecastResult
                    self?.collectionView.reloadData()
                    
                }
            case .failure(let error):
                #warning("Add error handling and remove print")
                print(error.localizedDescription)
            }
        }
    }
}


extension WeatherViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (forecastResult?.forecast.forecastday.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .red
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Section.count
    }
}
