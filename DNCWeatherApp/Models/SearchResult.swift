//
//  SearchResult.swift
//  DNCWeatherApp
//
//  Created by Ilya Tovstokory on 17.10.2023.
//

import Foundation

struct SearchResult: Codable {
    let id: Int
    let name: String
    let region: String
    let country: String
    let lat: Double
    let lon: Double
    let url: String
}
