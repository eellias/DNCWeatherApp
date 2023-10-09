//
//  WeatherViewController+Section.swift
//  DNCWeatherApp
//
//  Created by Ilya Tovstokory on 09.10.2023.
//

import Foundation

extension WeatherViewController {
    enum Section: Int, Hashable {
        case current
        case hourly
        case forecast
        
        static var count: Int {
            return Section.forecast.rawValue + 1
        }
    }
}
