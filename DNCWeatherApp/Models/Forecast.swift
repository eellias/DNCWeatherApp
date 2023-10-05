//
//  Forecast.swift
//  DNCWeatherApp
//
//  Created by Ilya Tovstokory on 05.10.2023.
//

import Foundation

struct Forecast: Codable {
    let forecastday: [Forecastday]
}
