//
//  MockDataHelper.swift
//  WeatherTests
//
//  Created by Gavin Lau on 17/3/2021.
//

import Foundation
@testable import Weather

class MockDataHelper {
    // swiftlint:disable function_body_length
    static func getMockWeatherResponse() -> WeatherResponse {
        let json = """
        {
            "coord": {
                "lon": 135,
                "lat": -25
            },
            "weather": [
                {
                    "id": 802,
                    "main": "Clouds",
                    "description": "scattered clouds",
                    "icon": "03d"
                }
            ],
            "base": "stations",
            "main": {
                "temp": 298.14,
                "feels_like": 290.32,
                "temp_min": 298.14,
                "temp_max": 298.14,
                "pressure": 1020,
                "humidity": 18,
                "sea_level": 1020,
                "grnd_level": 989
            },
            "visibility": 10000,
            "wind": {
                "speed": 8.14,
                "deg": 127,
                "gust": 8.72
            },
            "clouds": {
                "all": 36
            },
            "dt": 1615773383,
            "sys": {
                "country": "AU",
                "sunrise": 1615755677,
                "sunset": 1615799810
            },
            "timezone": 34200,
            "id": 2077456,
            "name": "Australia",
            "cod": 200
        }
        """
        let jsonData = json.data(using: .utf8)!
        let weatherResponse = try? JSONDecoder().decode(WeatherResponse.self, from: jsonData)
        return weatherResponse!
    }
}
