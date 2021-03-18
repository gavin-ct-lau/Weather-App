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
        let worker = WeatherInformationWorker()
        self.worker = worker

        let setupViewResponse = WeatherInformation.SetupView.Response()
        self.presenter?.presentSetupView(response: setupViewResponse)

        self.searchHistory = worker.getSearchHistoryFromUserDefault()
        let updateRecentSearchResponse = WeatherInformation.UpdateRecentSearch.Response(searchHistory: self.searchHistory)
        self.presenter?.presentUpdateRecentSearch(response: updateRecentSearchResponse)

        if !self.searchHistory.isEmpty, let mostRecentSearch = self.searchHistory.first {
            let weatherDataRequest = WeatherInformation.WeatherData.Request(
                searchType: .location(mostRecentSearch.location)
            )
            self.requestWeatherData(request: weatherDataRequest)
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
                    case .failure:
                        self?.presenter?.presentError(response: WeatherInformation.Error.Response())
                    }
                }
            } else {
                self.worker?.fetchWeatherDataByCityName(aSearchWord) { [weak self] (result) in
                    switch result {
                    case .success(let weatherResponse):
                        self?.presentWeatherData(weatherResponse: weatherResponse)
                    case .failure:
                        self?.presenter?.presentError(response: WeatherInformation.Error.Response())
                    }
                }
            }
        case let .location((latitude, longitude)):
            self.worker?.fetchWeatherDataByGeographicCoordinates(latitude: latitude,
                                                                 longitude: longitude) { [weak self] result in
                switch result {
                case .success(let weatherResponse):
                    self?.presentWeatherData(weatherResponse: weatherResponse)
                case .failure:
                    self?.presenter?.presentError(response: WeatherInformation.Error.Response())
                }
            }
        }
    }

    private func presentWeatherData(weatherResponse: WeatherResponse) {
        let response = WeatherInformation.WeatherData.Response(weatherResponse: weatherResponse)
        self.presenter?.presentWeatherData(response: response)

        if let latitude = weatherResponse.coordinate?.latitude,
           let longitude = weatherResponse.coordinate?.longitude {
            var searchHistory = self.searchHistory
            searchHistory.removeAll {
                $0.location.latitude == latitude &&
                    $0.location.longitude == longitude
            }
            searchHistory.insert((weatherResponse.cityName ?? "", Location(latitude, longitude)),
                                 at: 0)
            let request = WeatherInformation.UpdateRecentSearch.Request(searchHistory: searchHistory,
                                                                        shouldReloadTableView: true)
            self.requestUpdateRecentSearch(request: request)
        }
    }
}
