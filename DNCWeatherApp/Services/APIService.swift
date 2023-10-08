//
//  APIService.swift
//  DNCWeatherApp
//
//  Created by Ilya Tovstokory on 05.10.2023.
//

import Foundation
import Alamofire
import Security

struct APIService {
    let urlString: String
    private let apiKey = "82bb773b94314901a2d152250230510"
    
    init(urlString: String) {
        self.urlString = urlString
        
        saveAPIKey(apiKey: apiKey)
    }
    
    // MARK: - Functions for API key saving and reading from Keychain
    
    func saveAPIKey(apiKey: String) {
        let keychainQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "WeatherAppAPIKey",
            kSecValueData as String: apiKey.data(using: .utf8)!
        ]
    }

    func readAPIKey() -> String? {
        let keychainQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "WeatherAppAPIKey",
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(keychainQuery as CFDictionary, &item)

        if status == errSecSuccess {
            if let existingItem = item as? [String: Any],
               let apiKeyData = existingItem[kSecValueData as String] as? Data,
               let apiKey = String(data: apiKeyData, encoding: .utf8) {
                return apiKey
            }
        }

        return nil
    }
    
    // MARK: - Device language checking function

    func getCurrentLanguage() -> String {
        if let preferredLanguage = Locale.preferredLanguages.first {
            let components = NSLocale.components(fromLocaleIdentifier: preferredLanguage)
            
            if let languageCode = components[NSLocale.Key.languageCode.rawValue] {
                return languageCode
            }
        }
        return "en"
    }

    // MARK: - URL getting function
    
    func getURL() -> String {
        if let savedAPIKey = readAPIKey() {
            return "\(self.urlString)&key=\(savedAPIKey)&lang=\(getCurrentLanguage())"
        } else {
            return ""
        }
    }
    
    // MARK: - API request & JSON parsing function
    
    func getJSON<T: Decodable>(dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate,
                               keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys,
                               completion: @escaping (Result<T, APIError>) -> Void) {
        guard let url = URL(string: getURL()) else {
            completion(.failure(.invalidURL))
            return
        }
        
        AF.request(url).validate(statusCode: 200..<300).responseData { response in
            switch response.result {
            case .success(let data):
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = dateDecodingStrategy
                decoder.keyDecodingStrategy = keyDecodingStrategy
                do {
                    let decodedData = try decoder.decode(T.self, from: data)
                    completion(.success(decodedData))
                } catch {
                    completion(.failure(.decodingError(error.localizedDescription)))
                }
            case .failure(let error):
                completion(.failure(.dataTaskError(error.localizedDescription)))
            }
        }
    }
}
