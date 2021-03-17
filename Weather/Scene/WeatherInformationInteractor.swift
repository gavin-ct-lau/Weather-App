//
//  WeatherInformationInteractor.swift
//  Weather
//
//  Created by Gavin Lau on 17/3/2021.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

protocol WeatherInformationBusinessLogic {
    func requestSetupView(request: WeatherInformation.SetupView.Request)
    func requestWeatherData(request: WeatherInformation.WeatherData.Request)
    func requestUpdateRecentSearch(request: WeatherInformation.UpdateRecentSearch.Request)
}

protocol WeatherInformationDataStore {
}

class WeatherInformationInteractor: WeatherInformationBusinessLogic, WeatherInformationDataStore {
    var presenter: WeatherInformationPresentationLogic?
    var worker: WeatherInformationWorker?

    var searchHistory: [(cityName: String,
                         location: Location)] = []

    func requestSetupView(request: WeatherInformation.SetupView.Request) {
        self.worker = WeatherInformationWorker()
        self.presenter?.presentSetupView(response: WeatherInformation.SetupView.Response())

        self.searchHistory = self.worker?.getSearchHistoryFromUserDefault() ?? []
        self.presenter?.presentUpdateRecentSearch(response: WeatherInformation.UpdateRecentSearch.Response(searchHistory: self.searchHistory))

        if !self.searchHistory.isEmpty, let mostRecentSearch = self.searchHistory.first {
            self.requestWeatherData(request: WeatherInformation.WeatherData.Request(searchType: .location(mostRecentSearch.location)))
        }
    }

    func requestWeatherData(request: WeatherInformation.WeatherData.Request) {
        self.fetchWeatherData(searchType: request.searchType)
    }

    func requestUpdateRecentSearch(request: WeatherInformation.UpdateRecentSearch.Request) {
        self.worker?.setSearchHistoryToUserDefault(searchHistory: request.searchHistory)
        self.searchHistory = request.searchHistory
        if request.shouldReloadTableView {
            let response = WeatherInformation.UpdateRecentSearch.Response(
                searchHistory: self.searchHistory
            )
            self.presenter?.presentUpdateRecentSearch(response: response)
        }
    }
}

extension WeatherInformationInteractor {
    private func fetchWeatherData(searchType: WeatherInformation.SearchType) {
        switch searchType {
        case .input(let searchWord):
            guard let aSearchWord = searchWord, !aSearchWord.isEmpty else { return }

            if let zipCode = Int(aSearchWord) {
                self.worker?.fetchWeatherDataByZipCode(zipCode) { [weak self] (result) in
                    switch result {
                    case .success(let weatherResponse):
                        self?.presentWeatherData(weatherResponse: weatherResponse)
                    case .failure(let error):
                        // TODO: error handling
                        print(error.localizedDescription)
                    }
                }
            } else {
                self.worker?.fetchWeatherDataByCityName(aSearchWord) { [weak self] (result) in
                    switch result {
                    case .success(let weatherResponse):
                        self?.presentWeatherData(weatherResponse: weatherResponse)
                    case .failure(let error):
                        // TODO: error handling
                        print(error.localizedDescription)
                    }
                }
            }
        case let .location(latitude, longitude):
            self.worker?.fetchWeatherDataByGeographicCoordinates(latitude: latitude,
                                                                 longitude: longitude) { [weak self] result in
                switch result {
                case .success(let weatherResponse):
                    self?.presentWeatherData(weatherResponse: weatherResponse)
                case .failure(let error):
                    // TODO: error handling
                    print(error.localizedDescription)
                }
            }
        }
    }

    private func presentWeatherData(weatherResponse: WeatherResponse) {
        let response = WeatherInformation.WeatherData.Response(weatherResponse: weatherResponse)
        self.presenter?.presentWeatherData(response: response)

        if let cityName = weatherResponse.cityName, !cityName.isEmpty,
           let latitude = weatherResponse.coordinate?.latitude,
           let longitude = weatherResponse.coordinate?.longitude {
            var searchHistory = self.searchHistory
            searchHistory.removeAll {
                $0.cityName == cityName &&
                    $0.location.latitude == latitude &&
                    $0.location.longitude == longitude
            }
            searchHistory.insert((cityName, Location(latitude, longitude)), at: 0)
            let request = WeatherInformation.UpdateRecentSearch.Request(searchHistory: searchHistory,
                                                                        shouldReloadTableView: true)
            self.requestUpdateRecentSearch(request: request)
        }
    }
}
