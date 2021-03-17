//
//  WeatherInformationViewControllerTest.swift
//  WeatherTests
//
//  Created by Gavin Lau on 17/3/2021.
//

import XCTest
@testable import Weather

class WeatherInformationViewControllerTest: XCTestCase {
    class WeatherInformationRouterSpy: WeatherInformationRoutingLogic, WeatherInformationDataPassing {
        var dataStore: WeatherInformationDataStore?
    }

    class WeatherInformationInteractorSpy: WeatherInformationBusinessLogic {
        var isRequestSetupViewCalled = false
        var isRequestWeatherDataCalled = false
        var isRequestUpdateRecentSearchCalled = false

        var setupViewRequest: WeatherInformation.SetupView.Request?
        var weatherDataRequest: WeatherInformation.WeatherData.Request?
        var updateRecentSearchRequest: WeatherInformation.UpdateRecentSearch.Request?

        func requestSetupView(request: WeatherInformation.SetupView.Request) {
            self.isRequestSetupViewCalled = true
            self.setupViewRequest = request
        }

        func requestWeatherData(request: WeatherInformation.WeatherData.Request) {
            self.isRequestWeatherDataCalled = true
            self.weatherDataRequest = request
        }

        func requestUpdateRecentSearch(request: WeatherInformation.UpdateRecentSearch.Request) {
            self.isRequestUpdateRecentSearchCalled = true
            self.updateRecentSearchRequest = request
        }
    }

    func testDisplaySetupView(viewModel: WeatherInformation.SetupView.ViewModel) {
        // Given
        let sut = WeatherInformationViewController()
        let weatherInformationRouterSpy = WeatherInformationRouterSpy()
        sut.router = weatherInformationRouterSpy
        let weatherInformationInteractorSpy = WeatherInformationInteractorSpy()
        sut.interactor = weatherInformationInteractorSpy

        // When
        sut.displaySetupView(viewModel: WeatherInformation.SetupView.ViewModel())

        // Then
        XCTAssertTrue(sut.searchBar.showsBookmarkButton)
        XCTAssertEqual(sut.searchBar.image(for: .bookmark, state: .normal), UIImage(systemName: "mappin.and.ellipse"))
        XCTAssertEqual(sut.searchBar.placeholder, "city name or zip code")
        XCTAssertNil(sut.weatherInformationView.cityNameLabel.text)
        XCTAssertNil(sut.weatherInformationView.weatherIconImageView.image)
        XCTAssertTrue(sut.weatherInformationView.weatherIconImageView.isHidden)
        XCTAssertNil(sut.weatherInformationView.weatherLabel.text)
        XCTAssertNil(sut.weatherInformationView.temperatureLabel.text)
        XCTAssertNil(sut.weatherInformationView.temperatureFeelsLikeLabel.text)
    }

    func testDisplayWeatherData(viewModel: WeatherInformation.WeatherData.ViewModel) {
        // Given
        let sut = WeatherInformationViewController()
        let weatherInformationRouterSpy = WeatherInformationRouterSpy()
        sut.router = weatherInformationRouterSpy
        let weatherInformationInteractorSpy = WeatherInformationInteractorSpy()
        sut.interactor = weatherInformationInteractorSpy

        let viewModel = WeatherInformation.WeatherData.ViewModel(
            cityName: "London",
            iconURL: nil,
            weather: "clouds",
            temperature: "4.99°C",
            temperatureFeelsLike: "Feels like 1.15°C"
        )

        // When
        sut.displayWeatherData(viewModel: viewModel)

        // Then
        XCTAssertEqual(sut.weatherInformationView.cityNameLabel.text, viewModel.cityName)
        XCTAssertNil(sut.weatherInformationView.weatherIconImageView.image)
        XCTAssertTrue(sut.weatherInformationView.weatherIconImageView.isHidden)
        XCTAssertEqual(sut.weatherInformationView.weatherLabel.text, viewModel.weather)
        XCTAssertEqual(sut.weatherInformationView.temperatureLabel.text, viewModel.temperature)
        XCTAssertEqual(sut.weatherInformationView.temperatureFeelsLikeLabel.text, viewModel.temperatureFeelsLike)
    }

    func testDisplayUpdateRecentSearch(viewModel: WeatherInformation.UpdateRecentSearch.ViewModel) {
        // Given
        let sut = WeatherInformationViewController()
        let weatherInformationRouterSpy = WeatherInformationRouterSpy()
        sut.router = weatherInformationRouterSpy
        let weatherInformationInteractorSpy = WeatherInformationInteractorSpy()
        sut.interactor = weatherInformationInteractorSpy

        let searchHistory = ("London", Location(20, -20))
        let viewModel = WeatherInformation.UpdateRecentSearch.ViewModel(
            searchHistory: [searchHistory]
        )

        // When
        sut.displayUpdateRecentSearch(viewModel: viewModel)

        // Then
        XCTAssertEqual(sut.searchHistory.count, viewModel.searchHistory.count)
        XCTAssertEqual(sut.tableView.numberOfRows(inSection: 0), 1)
    }
}
