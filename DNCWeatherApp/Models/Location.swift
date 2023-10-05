//
//  Location.swift
//  DNCWeatherApp
//
//  Created by Ilya Tovstokory on 05.10.2023.
//

import Foundation

struct Location: Codable {
    let name: String
    let region: String
    let country: String
    let localtime: String

    enum CodingKeys: String, CodingKey {
        case name
        case region
        case country
        case localtime
    }
}
