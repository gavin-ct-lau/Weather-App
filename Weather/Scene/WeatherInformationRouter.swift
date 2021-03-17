//
//  WeatherInformationRouter.swift
//  Weather
//
//  Created by Gavin Lau on 17/3/2021.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

protocol WeatherInformationRoutingLogic {
}

protocol WeatherInformationDataPassing {
    var dataStore: WeatherInformationDataStore? { get }
}

class WeatherInformationRouter: WeatherInformationRoutingLogic, WeatherInformationDataPassing {
    weak var viewController: WeatherInformationViewController?
    var dataStore: WeatherInformationDataStore?
}
