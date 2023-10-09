//
//  APIError.swift
//  DNCWeatherApp
//
//  Created by Ilya Tovstokory on 05.10.2023.
//

import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case dataTaskError(String)
    case decodingError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return NSLocalizedString("The endpoint URL is invalid.", comment: "")
        case .dataTaskError(let string):
            return NSLocalizedString(string, comment: "")
        case .decodingError(let string):
            return NSLocalizedString(string, comment: "")
        }
    }
}
