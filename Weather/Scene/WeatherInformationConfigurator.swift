//
//  WeatherInformationConfigurator.swift
//  Weather
//
//  Created by Gavin Lau on 17/3/2021.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

class WeatherInformationConfigurator {
    class func createScene() -> WeatherInformationViewController {
        let viewController = WeatherInformationViewController(nibName: nil, bundle: nil)
        let interactor = WeatherInformationInteractor()
        let presenter = WeatherInformationPresenter()
        let router = WeatherInformationRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor

        return viewController
    }
}
