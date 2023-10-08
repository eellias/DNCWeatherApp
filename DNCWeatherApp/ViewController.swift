//
//  ViewController.swift
//  DNCWeatherApp
//
//  Created by Ilya Tovstokory on 05.10.2023.
//

import UIKit

class ViewController: UIViewController {
    var currentResult: CurrentResult?
    var forecastResult: ForecastResult?

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchCurrentResult()
        fetchForecastResult()
    }
    
    // MARK: - Fetching functions

    func fetchCurrentResult() {
        let apiService = APIService(urlString: "http://api.weatherapi.com/v1/current.json?q=London")
        
        apiService.getJSON { (result: Result<CurrentResult, APIError>) in
            switch result {
            case .success(let currentResult):
                DispatchQueue.main.async {
                    self.currentResult = currentResult
                    print(self.currentResult)
                    print("\n\n\n\n")
                }
            case .failure(let error):
                #warning("Add error handling and remove print")
                print(error.localizedDescription)
            }
        }
    }
    
    func fetchForecastResult() {
        let apiService = APIService(urlString: "http://api.weatherapi.com/v1/forecast.json?q=Kharkiv&days=3")
        
        apiService.getJSON { (result: Result<ForecastResult, APIError>) in
            switch result {
            case .success(let forecastResult):
                DispatchQueue.main.async {
                    self.forecastResult = forecastResult
                    print(self.forecastResult)
                }
            case .failure(let error):
                #warning("Add error handling and remove print")
                print(error.localizedDescription)
            }
        }
    }
}

