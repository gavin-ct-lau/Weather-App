//
//  WeatherInformationModels.swift
//  Weather
//
//  Created by Gavin Lau on 17/3/2021.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

typealias Location = (latitude: Double,
                      longitude: Double)

enum WeatherInformation {
    enum SetupView {
        struct Request {}
        struct Response {}
        struct ViewModel {}
    }

    enum WeatherData {
        struct Request {
            let searchType: SearchType
        }
        struct Response {
            let weatherResponse: WeatherResponse
        }
        struct ViewModel {
            let cityName: String?
            let iconURL: URL?
            let weather: String?
            let temperature: String?
            let temperatureFeelsLike: String?
        }
    }

    // swiftlint:disable identifier_name
    enum SearchType {
        case input(String?)
        case location(Location)
    }

    enum UpdateRecentSearch {
        struct Request {
            let searchHistory: [(cityName: String,
                                 location: Location)]
            let shouldReloadTableView: Bool
        }
        struct Response {
            let searchHistory: [(cityName: String,
                                 location: Location)]
        }
        struct ViewModel {
            let searchHistory: [(cityName: String,
                                 location: Location)]
        }
    }

    enum Error {
        struct Request {}
        struct Response {}
        struct ViewModel {
            let title: String?
            let message: String?
        }
    }
}
