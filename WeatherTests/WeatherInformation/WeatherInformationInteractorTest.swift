//
//  WeatherInformationInteractorTest.swift
//  WeatherTests
//
//  Created by Gavin Lau on 17/3/2021.
//

import XCTest
@testable import Weather

class WeatherInformationInteractorTest: XCTestCase {
    class WeatherInformationPresenterSpy: WeatherInformationPresentationLogic {
        var isPresentSetupViewCalled = false
        var isPresentWeatherDataCalled = false
        var isPresentUpdateRecentSearchCalled = false
        var isPresentErrorCalled = false

        var setupViewResponse: WeatherInformation.SetupView.Response?
        var weatherDataResponse: WeatherInformation.WeatherData.Response?
        var updateRecentSearchResponse: WeatherInformation.UpdateRecentSearch.Response?
        var errorResponse: WeatherInformation.Error.Response?

        func presentSetupView(response: WeatherInformation.SetupView.Response) {
            self.isPresentSetupViewCalled = true
            self.setupViewResponse = response
        }

        func presentWeatherData(response: WeatherInformation.WeatherData.Response) {
            self.isPresentWeatherDataCalled = true
            self.weatherDataResponse = response
        }

        func presentUpdateRecentSearch(response: WeatherInformation.UpdateRecentSearch.Response) {
            self.isPresentUpdateRecentSearchCalled = true
            self.updateRecentSearchResponse = response
        }

        func presentError(response: WeatherInformation.Error.Response) {
            self.isPresentErrorCalled = true
            self.errorResponse = response
        }
    }

    class WeatherInformationWorkerSpy: WeatherInformationWorker {
        var isFetchWeatherDataByZipCodeCalled = false
        var isFetchWeatherDataByCityNameCalled = false
        var isFetchWeatherDataByGeographicCoordinatesCalled = false
        var isGetSearchHistoryFromUserDefaultCalled = false
        var isSetSearchHistoryToUserDefaultCalled = false

        override func fetchWeatherDataByZipCode(_ zipCode: Int,
                                                completion: @escaping (Result<WeatherResponse, Error>) -> Void) {
            self.isFetchWeatherDataByZipCodeCalled = true
            completion(.success(MockDataHelper.getMockWeatherResponse()))
        }

        override func fetchWeatherDataByCityName(_ cityName: String,
                                                 completion: @escaping (Result<WeatherResponse, Error>) -> Void) {
            self.isFetchWeatherDataByCityNameCalled = true
            completion(.success(MockDataHelper.getMockWeatherResponse()))
        }

        override func fetchWeatherDataByGeographicCoordinates(latitude: Double,
                                                              longitude: Double,
                                                              completion: @escaping (Result<WeatherResponse, Error>) -> Void) {
            self.isFetchWeatherDataByGeographicCoordinatesCalled = true
            completion(.success(MockDataHelper.getMockWeatherResponse()))
        }

        override func getSearchHistoryFromUserDefault() -> [(cityName: String,
                                                             location: Location)] {
            self.isGetSearchHistoryFromUserDefaultCalled = true
            return [("London", Location(20, -20))]
        }

        override func setSearchHistoryToUserDefault(searchHistory: [(cityName: String,
                                                                     location: Location)]) {
            self.isSetSearchHistoryToUserDefaultCalled = true
        }
    }

    func testRequestSetupView() {
        // Given
        let sut = WeatherInformationInteractor()
        let weatherInformationPresenterSpy = WeatherInformationPresenterSpy()
        sut.presenter = weatherInformationPresenterSpy
        let weatherInformationWorkerSpy = WeatherInformationWorkerSpy()
        sut.worker = weatherInformationWorkerSpy

        // When
        sut.requestSetupView(request: WeatherInformation.SetupView.Request())

        // Then
        XCTAssertTrue(weatherInformationPresenterSpy.isPresentSetupViewCalled)
        XCTAssertTrue(weatherInformationPresenterSpy.isPresentUpdateRecentSearchCalled)
    }

    func testRequestWeatherData() {
        // Given
        let sut = WeatherInformationInteractor()
        let weatherInformationPresenterSpy = WeatherInformationPresenterSpy()
        sut.presenter = weatherInformationPresenterSpy
        let weatherInformationWorkerSpy = WeatherInformationWorkerSpy()
        sut.worker = weatherInformationWorkerSpy

        // When
        sut.requestWeatherData(request: WeatherInformation.WeatherData.Request(searchType: .input("London")))

        // Then
        XCTAssertTrue(weatherInformationPresenterSpy.isPresentWeatherDataCalled)
        XCTAssertNotNil(weatherInformationPresenterSpy.weatherDataResponse)
        XCTAssertTrue(weatherInformationPresenterSpy.isPresentUpdateRecentSearchCalled)
        XCTAssertTrue(weatherInformationWorkerSpy.isSetSearchHistoryToUserDefaultCalled)

    }

    func testRequestUpdateRecentSearch() {
        // Given
        let sut = WeatherInformationInteractor()
        let weatherInformationPresenterSpy = WeatherInformationPresenterSpy()
        sut.presenter = weatherInformationPresenterSpy
        let weatherInformationWorkerSpy = WeatherInformationWorkerSpy()
        sut.worker = weatherInformationWorkerSpy

        // When
        let request = WeatherInformation.UpdateRecentSearch.Request(
            searchHistory: [("London", Location(20, -20))],
            shouldReloadTableView: true
        )
        sut.requestUpdateRecentSearch(request: request)

        // Then
        XCTAssertTrue(weatherInformationWorkerSpy.isSetSearchHistoryToUserDefaultCalled)
        XCTAssertTrue(weatherInformationPresenterSpy.isPresentUpdateRecentSearchCalled)
        XCTAssertNotNil(weatherInformationPresenterSpy.updateRecentSearchResponse)
    }
}
