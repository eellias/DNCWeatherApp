//
//  Forecastday.swift
//  DNCWeatherApp
//
//  Created by Ilya Tovstokory on 05.10.2023.
//

import Foundation

struct Forecastday: Codable {
    let date: String
    let day: Day
    let hour: [Hour]
}
