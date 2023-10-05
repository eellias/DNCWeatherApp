//
//  APIService.swift
//  DNCWeatherApp
//
//  Created by Ilya Tovstokory on 05.10.2023.
//

import Foundation
import Alamofire

struct APIService {
    let urlString: String
    let apiKey = "82bb773b94314901a2d152250230510"
    
    func getJSON<T: Decodable>(dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate,
                               keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys,
                               completion: @escaping (Result<T, APIError>) -> Void) {
        guard let url = URL(string: urlString) else {
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
