//
//  WeatherInformationWorker.swift
//  Weather
//
//  Created by Gavin Lau on 17/3/2021.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

class WeatherInformationWorker {
    let apiManager: APIManager
    init(apiManager: APIManager = APIManager.shared) {
        self.apiManager = apiManager
    }

    func fetchWeatherDataByZipCode(_ zipCode: Int,
                                   completion: @escaping (Result<WeatherResponse, Error>) -> Void) {
        self.apiManager.fetchWeatherDataByZipCode(zipCode, completion: completion)
    }

    func fetchWeatherDataByCityName(_ cityName: String,
                                    completion: @escaping (Result<WeatherResponse, Error>) -> Void) {
        self.apiManager.fetchWeatherDataByCityName(cityName, completion: completion)
    }

    func fetchWeatherDataByGeographicCoordinates(latitude: Double,
                                                 longitude: Double,
                                                 completion: @escaping (Result<WeatherResponse, Error>) -> Void) {
        self.apiManager.fetchWeatherDataByGeographicCoordinates(latitude: latitude,
                                                                longitude: longitude,
                                                                completion: completion)
    }

    func getSearchHistoryFromUserDefault() -> [(cityName: String,
                                                location: Location)] {
        let dicts = UserDefaults.standard.array(forKey: Constant.mostRecentSearchKey) as? [[String: Any]] ?? [[:]]
        return dicts.compactMap {
            guard let cityName = $0[Constant.mostRecentSearchValueKeyCityName] as? String,
                  let latitude = $0[Constant.mostRecentSearchValueKeyLatitude] as? Double,
                  let longitude = $0[Constant.mostRecentSearchValueKeyLongitude] as? Double else { return nil }
            return (cityName, Location(latitude, longitude))
        }
    }

    func setSearchHistoryToUserDefault(searchHistory: [(cityName: String,
                                                        location: Location)]) {
        let dict = searchHistory.map { [Constant.mostRecentSearchValueKeyCityName: $0.cityName,
                                        Constant.mostRecentSearchValueKeyLatitude: $0.location.latitude,
                                        Constant.mostRecentSearchValueKeyLongitude: $0.location.longitude] }
        UserDefaults.standard.set(dict, forKey: Constant.mostRecentSearchKey)
    }
}
