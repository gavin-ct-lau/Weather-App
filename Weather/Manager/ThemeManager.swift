//
//  ThemeManager.swift
//  Weather
//
//  Created by Gavin Lau on 17/3/2021.
//

import UIKit

enum Theme: String {
    case australia = "AU"
    case canada = "CA"

    var backgroundColor: UIColor {
        switch self {
        case .australia:    return UIColor(red: 0, green: 0, blue: 139/255, alpha: 1.0)
        case .canada:       return .red
        }
    }

    var textColor: UIColor {
        switch self {
        case .australia, .canada: return .white
        }
    }
}

class ThemeManager {
    static let shared: ThemeManager = ThemeManager()

    var currentTheme: Theme {
        return Theme(rawValue: Locale.current.regionCode ?? "") ?? .australia
    }
}
