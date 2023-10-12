//
//  Date+Format.swift
//  DNCWeatherApp
//
//  Created by Ilya Tovstokory on 12.10.2023.
//

import Foundation

extension Date {
    func dayOfWeek() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EE"
        dateFormatter.locale = Locale.current
        let date = dateFormatter.string(from: self)
        return NSLocalizedString(date, comment: "Date label")
    }

    func hours() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH"
        return dateFormatter.string(from: self)
    }
}
