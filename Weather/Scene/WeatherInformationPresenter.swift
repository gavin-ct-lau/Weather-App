//
//  WeatherInformationPresenter.swift
//  Weather
//
//  Created by Gavin Lau on 17/3/2021.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

protocol WeatherInformationPresentationLogic {
    func presentSetupView(response: WeatherInformation.SetupView.Response)
    func presentWeatherData(response: WeatherInformation.WeatherData.Response)
    func presentUpdateRecentSearch(response: WeatherInformation.UpdateRecentSearch.Response)
}

class WeatherInformationPresenter: WeatherInformationPresentationLogic {
    weak var viewController: WeatherInformationDisplayLogic?

    func presentSetupView(response: WeatherInformation.SetupView.Response) {
        self.viewController?.displaySetupView(viewModel: WeatherInformation.SetupView.ViewModel())
    }

    func presentWeatherData(response: WeatherInformation.WeatherData.Response) {
        var iconURL: URL?
        var temperatureString: String?
        var temperatureFeelsLikeString: String?

        if let iconName = response.weatherResponse.weather.first?.icon {
            iconURL = URL(string: "http://openweathermap.org/img/w/\(iconName).png")
        }
        if let temperature = response.weatherResponse.temperature?.value {
            temperatureString = "\(temperature)°C"
        }
        if let temperatureFeelsLike = response.weatherResponse.temperature?.feelsLikeValue {
            temperatureFeelsLikeString = "Feels like \(temperatureFeelsLike)°C"
        }

        let viewModel = WeatherInformation.WeatherData.ViewModel(
            cityName: response.weatherResponse.cityName,
            iconURL: iconURL,
            weather: response.weatherResponse.weather.first?.description,
            temperature: temperatureString,
            temperatureFeelsLike: temperatureFeelsLikeString
        )
        self.viewController?.displayWeatherData(viewModel: viewModel)
    }

    func presentUpdateRecentSearch(response: WeatherInformation.UpdateRecentSearch.Response) {
        let viewModel = WeatherInformation.UpdateRecentSearch.ViewModel(searchHistory: response.searchHistory)
        self.viewController?.displayUpdateRecentSearch(viewModel: viewModel)
    }
}
