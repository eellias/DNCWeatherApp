//
//  Hour.swift
//  DNCWeatherApp
//
//  Created by Ilya Tovstokory on 05.10.2023.
//

import Foundation

struct Hour: Codable {
    let time: String
    let tempC: Double
    let tempF: Double
    let isDay: Int
    let condition: Condition
    let chanceOfRain: Int

    enum CodingKeys: String, CodingKey {
        case time
        case tempC = "temp_c"
        case tempF = "temp_f"
        case isDay = "is_day"
        case condition
        case chanceOfRain = "chance_of_rain"
    }
}
