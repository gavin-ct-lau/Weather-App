//
//  WeatherInformationPresenterTest.swift
//  WeatherTests
//
//  Created by Gavin Lau on 17/3/2021.
//

import XCTest
@testable import Weather

class WeatherInformationPresenterTest: XCTestCase {
    class WeatherInformationViewControllerSpy: UIViewController, WeatherInformationDisplayLogic {
        var isDisplaySetupViewCalled = false
        var isDisplayWeatherDataCalled = false
        var isDisplayUpdateRecentSearchCalled = false

        var setupViewViewModel: WeatherInformation.SetupView.ViewModel?
        var weatherDataViewModel: WeatherInformation.WeatherData.ViewModel?
        var updateRecentSearchViewModel: WeatherInformation.UpdateRecentSearch.ViewModel?

        func displaySetupView(viewModel: WeatherInformation.SetupView.ViewModel) {
            self.isDisplaySetupViewCalled = true
            self.setupViewViewModel = viewModel
        }

        func displayWeatherData(viewModel: WeatherInformation.WeatherData.ViewModel) {
            self.isDisplayWeatherDataCalled = true
            self.weatherDataViewModel = viewModel
        }

        func displayUpdateRecentSearch(viewModel: WeatherInformation.UpdateRecentSearch.ViewModel) {
            self.isDisplayUpdateRecentSearchCalled = true
            self.updateRecentSearchViewModel = viewModel
        }
    }

    func testPresentSetupView(response: WeatherInformation.SetupView.Response) {
        // Given
        let sut = WeatherInformationPresenter()
        let weatherInformationViewControllerSpy = WeatherInformationViewControllerSpy()
        sut.viewController = weatherInformationViewControllerSpy

        // When
        sut.presentSetupView(response: WeatherInformation.SetupView.Response())

        // Then
        XCTAssertTrue(weatherInformationViewControllerSpy.isDisplaySetupViewCalled)
        XCTAssertNotNil(weatherInformationViewControllerSpy.setupViewViewModel)
    }

    func testPresentWeatherData(response: WeatherInformation.WeatherData.Response) {
        // Given
        let sut = WeatherInformationPresenter()
        let weatherInformationViewControllerSpy = WeatherInformationViewControllerSpy()
        sut.viewController = weatherInformationViewControllerSpy

        let weatherResponse = MockDataHelper.getMockWeatherResponse()
        let response = WeatherInformation.WeatherData.Response(
            weatherResponse: weatherResponse
        )

        // When
        sut.presentWeatherData(response: response)

        // Then
        XCTAssertTrue(weatherInformationViewControllerSpy.isDisplayWeatherDataCalled)
        XCTAssertNotNil(weatherInformationViewControllerSpy.weatherDataViewModel)
        XCTAssertEqual(weatherInformationViewControllerSpy.weatherDataViewModel?.cityName,
                       weatherResponse.cityName)
        XCTAssertEqual(weatherInformationViewControllerSpy.weatherDataViewModel?.iconURL,
                       URL(string: "http://openweathermap.org/img/w/\(weatherResponse.weather.first?.icon ?? "").png"))
        XCTAssertEqual(weatherInformationViewControllerSpy.weatherDataViewModel?.weather,
                       weatherResponse.weather.first?.description)
        XCTAssertEqual(weatherInformationViewControllerSpy.weatherDataViewModel?.temperature,
                       "\(weatherResponse.temperature?.value ?? 0.0)°C")
        XCTAssertEqual(weatherInformationViewControllerSpy.weatherDataViewModel?.temperatureFeelsLike,
                       "\(weatherResponse.temperature?.feelsLikeValue ?? 0.0)")
    }

    func testPresentUpdateRecentSearch(response: WeatherInformation.UpdateRecentSearch.Response) {
        // Given
        let sut = WeatherInformationPresenter()
        let weatherInformationViewControllerSpy = WeatherInformationViewControllerSpy()
        sut.viewController = weatherInformationViewControllerSpy

        // When
        sut.presentSetupView(response: WeatherInformation.SetupView.Response())

        // Then
        XCTAssertTrue(weatherInformationViewControllerSpy.isDisplaySetupViewCalled)
    }
}
