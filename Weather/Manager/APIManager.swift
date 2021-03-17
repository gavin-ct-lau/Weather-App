//
//  APIManager.swift
//  Weather
//
//  Created by Gavin Lau on 15/3/2021.
//

import Foundation
import Alamofire

class APIManager {
    static let shared: APIManager = APIManager()

    private func getRepository(queryItems: [URLQueryItem]) -> URL? {
        var components = URLComponents()
        components.scheme = Constant.apiScheme
        components.host = Constant.apiHost
        components.path = Constant.apiPath
        components.queryItems = queryItems
        return components.url
    }

    func fetchWeatherDataByZipCode(_ zipCode: Int,
                                   completion: @escaping (Result<WeatherResponse, Error>) -> Void) {
        let queryItems = [URLQueryItem(name: "zip", value: String(zipCode)),
                          URLQueryItem(name: "appid", value: Constant.apiKey),
                          URLQueryItem(name: "lang", value: "en"),
                          URLQueryItem(name: "units", value: "metric")]
        if let url = self.getRepository(queryItems: queryItems) {
            self.fetchWeatherData(url: url, completion: completion)
        }
    }

    func fetchWeatherDataByCityName(_ cityName: String,
                                    completion: @escaping (Result<WeatherResponse, Error>) -> Void) {
        let queryItems = [URLQueryItem(name: "q", value: cityName),
                          URLQueryItem(name: "appid", value: Constant.apiKey),
                          URLQueryItem(name: "lang", value: "en"),
                          URLQueryItem(name: "units", value: "metric")]
        if let url = self.getRepository(queryItems: queryItems) {
            self.fetchWeatherData(url: url, completion: completion)
        }
    }

    func fetchWeatherDataByGeographicCoordinates(latitude: Double,
                                                 longitude: Double,
                                                 completion: @escaping (Result<WeatherResponse, Error>) -> Void) {
        let queryItems = [URLQueryItem(name: "lat", value: String(latitude)),
                          URLQueryItem(name: "lon", value: String(longitude)),
                          URLQueryItem(name: "appid", value: Constant.apiKey),
                          URLQueryItem(name: "units", value: "metric")]
        if let url = self.getRepository(queryItems: queryItems) {
            self.fetchWeatherData(url: url, completion: completion)
        }
    }

    private func fetchWeatherData(url: URL,
                                  completion: @escaping (Result<WeatherResponse, Error>) -> Void) {
        AF.request(url)
            .validate(statusCode: 200..<300)
            .responseDecodable(completionHandler: { (response: DataResponse<WeatherResponse, AFError>) in
                switch response.result {
                case .success(let weatherResponse):
                    completion(.success(weatherResponse))
                case .failure(let error):
                    completion(.failure(error))
                }
            })
    }
}
