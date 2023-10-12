//
//  APIService.swift
//  DNCWeatherApp
//
//  Created by Ilya Tovstokory on 05.10.2023.
//

import Foundation
import Alamofire
import Security

class APIService {
    public static let shared = APIService()
    private let apiKey = "82bb773b94314901a2d152250230510"
    
    init() {
        saveAPIKey(apiKey: apiKey)
    }
    
    // MARK: - Functions for saving and reading API key from Keychain
    
    func saveAPIKey(apiKey: String) {
        let keychainQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "WeatherAppAPIKey",
            kSecValueData as String: apiKey.data(using: .utf8)!
        ]
        
        let status = SecItemAdd(keychainQuery as CFDictionary, nil)

        if status != errSecSuccess {
            print("API key saving error: \(status)")
        }
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
    
    func getURL(_ url: String) -> String {
        if let savedAPIKey = readAPIKey() {
            return "\(url)&key=\(savedAPIKey)&lang=\(getCurrentLanguage())"
        } else {
            return ""
        }
    }
    
    // MARK: - API request & JSON parsing function
    
    func getJSON<T: Decodable>(urlString: String,
                               dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate,
                               keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys,
                               completion: @escaping (Result<T, APIError>) -> Void) {
        guard let url = URL(string: getURL(urlString)) else {
            completion(.failure(.invalidURL))
            return
        }
        
        AF.request(url).validate(statusCode: 200..<300).responseData { response in
            switch response.result {
            case .success(let data):
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
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
