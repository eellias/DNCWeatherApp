//
//  ListSection.swift
//  DNCWeatherApp
//
//  Created by Ilya Tovstokory on 10.10.2023.
//

import Foundation

struct CurrentLocation {
    let current: Current
    let location: Location
}

enum ListSection{
    case current(CurrentLocation)
    case hourly([Hour])
    case forecast([Forecastday])
    
    var items: [Any] {
        switch self {
        case .current(let data):
            return [data]
        case .hourly(let array):
            return array
        case .forecast(let array):
            return array
        }
    }
    
    var count: Int {
        items.count
    }
    
    var title: String {
        switch self {
        case .current(_):
            return ""
        case .hourly(_):
            return ""
        case .forecast(_):
            return NSLocalizedString("Daily forecast", comment: "Daily forecast section title")
        }
    }
}
