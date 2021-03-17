//
//  Weather.swift
//  Weather
//
//  Created by Gavin Lau on 15/3/2021.
//

import Foundation

struct WeatherResponse: Decodable {
    let coordinate: Coordinate?
    let weather: [Weather]
    let base: String?
    let temperature: Temperature?
    let timezone: Int?
    let id: Int?
    let cityName: String?
    let code: Int?

    enum CodingKeys: String, CodingKey {
        case coordinate = "coord"
        case weather
        case base
        case temperature = "main"
        case timezone
        case id
        case cityName = "name"
        case code = "cod"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.coordinate = try container.decodeIfPresent(Coordinate.self, forKey: .coordinate)
        self.weather = try container.decodeIfPresent([Weather].self, forKey: .weather) ?? []
        self.base = try container.decodeIfPresent(String.self, forKey: .base)
        self.temperature = try container.decodeIfPresent(Temperature.self, forKey: .temperature)
        self.timezone = try container.decodeIfPresent(Int.self, forKey: .timezone)
        self.id = try container.decodeIfPresent(Int.self, forKey: .id)
        self.cityName = try container.decodeIfPresent(String.self, forKey: .cityName)
        self.code = try container.decodeIfPresent(Int.self, forKey: .code)
    }
}

struct Coordinate: Decodable {
    let longitude: Double?
    let latitude: Double?

    enum CodingKeys: String, CodingKey {
        case longitude = "lon"
        case latitude = "lat"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.longitude = try container.decodeIfPresent(Double.self, forKey: .longitude)
        self.latitude = try container.decodeIfPresent(Double.self, forKey: .latitude)
    }
}

struct Weather: Decodable {
    let id: Int
    let main: String?
    let description: String?
    let icon: String?
}

struct Temperature: Decodable {
    let value: Double?
    let feelsLikeValue: Double?
    let minValue: Double?
    let maxValue: Double?
    let pressure: Double?
    let humidity: Double?

    enum CodingKeys: String, CodingKey {
        case value = "temp"
        case feelsLikeValue = "feels_like"
        case minValue = "temp_min"
        case maxValue = "temp_max"
        case pressure
        case humidity

    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.value = try container.decodeIfPresent(Double.self, forKey: .value)
        self.feelsLikeValue = try container.decodeIfPresent(Double.self, forKey: .feelsLikeValue)
        self.minValue = try container.decodeIfPresent(Double.self, forKey: .minValue)
        self.maxValue = try container.decodeIfPresent(Double.self, forKey: .maxValue)
        self.pressure = try container.decodeIfPresent(Double.self, forKey: .pressure)
        self.humidity = try container.decodeIfPresent(Double.self, forKey: .humidity)
    }
}
