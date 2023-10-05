//
//  CurrentResult.swift
//  DNCWeatherApp
//
//  Created by Ilya Tovstokory on 05.10.2023.
//

import Foundation

struct CurrentResult: Codable {
    let location: Location
    let current: Current
}
