//
//  Constant.swift
//  Weather
//
//  Created by Gavin Lau on 17/3/2021.
//

import Foundation

struct Constant {
    // API
    static let apiKey = "95d190a434083879a6398aafd54d9e73"
    static let apiScheme = "http"
    static let apiHost = "api.openweathermap.org"
    static let apiPath = "/data/2.5/weather"

    // Most Recent Search
    static let mostRecentSearchKey = "weather_most_recent_search_key"
    static let mostRecentSearchValueKeyCityName = "cityName"
    static let mostRecentSearchValueKeyLatitude = "latitude"
    static let mostRecentSearchValueKeyLongitude = "longitude"
}
