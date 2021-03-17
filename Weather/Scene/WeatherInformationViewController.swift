//
//  WeatherInformationViewController.swift
//  Weather
//
//  Created by Gavin Lau on 17/3/2021.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit
import CoreLocation

protocol WeatherInformationDisplayLogic: class {
    func displaySetupView(viewModel: WeatherInformation.SetupView.ViewModel)
    func displayWeatherData(viewModel: WeatherInformation.WeatherData.ViewModel)
    func displayUpdateRecentSearch(viewModel: WeatherInformation.UpdateRecentSearch.ViewModel)
    func displayError(viewModel: WeatherInformation.Error.ViewModel)
}

class WeatherInformationViewController: UIViewController, WeatherInformationDisplayLogic {
    var interactor: WeatherInformationBusinessLogic?
    var router: (WeatherInformationRoutingLogic & WeatherInformationDataPassing)?

    let themeManager: ThemeManager
    init(themeManager: ThemeManager = ThemeManager.shared,
         nibName nibNameOrNil: String?,
         bundle nibBundleOrNil: Bundle?) {
        self.themeManager = themeManager
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let locationManager = CLLocationManager()

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var weatherInformationView: WeatherInformationView!

    var searchHistory: [(cityName: String,
                         location: Location)] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.configStyle()

        self.interactor?.requestSetupView(request: WeatherInformation.SetupView.Request())
    }

    func configStyle() {
        let theme = self.themeManager.currentTheme
        self.view.backgroundColor = theme.backgroundColor
        self.tableView.backgroundColor = theme.backgroundColor
        self.searchBar.barTintColor = theme.backgroundColor
        self.searchBar.tintColor = theme.textColor
        self.searchBar.searchTextField.textColor = theme.textColor
        self.searchBar.searchTextField.tintColor = theme.textColor
    }

    private func requestWeatherData(searchWord: String?) {
        self.view.endEditing(true)
        let request = WeatherInformation.WeatherData.Request(searchType: .input(searchWord))
        self.interactor?.requestWeatherData(request: request)
    }
}

extension WeatherInformationViewController {
    func displaySetupView(viewModel: WeatherInformation.SetupView.ViewModel) {
        self.tableView.delegate = self
        self.tableView.dataSource = self

        self.searchBar.showsBookmarkButton = true
        self.searchBar.setImage(UIImage(systemName: "mappin.and.ellipse"),
                                for: .bookmark,
                                state: .normal)
        self.searchBar.placeholder = "city name or zip code"
        self.searchBar.delegate = self

        self.weatherInformationView.configView(cityName: nil,
                                               iconURL: nil,
                                               weather: nil,
                                               temperature: nil,
                                               temperatureFeelsLike: nil)
        self.weatherInformationView.configStyle(themeManager: self.themeManager)
    }

    func displayWeatherData(viewModel: WeatherInformation.WeatherData.ViewModel) {
        self.weatherInformationView.configView(cityName: viewModel.cityName,
                                               iconURL: viewModel.iconURL,
                                               weather: viewModel.weather,
                                               temperature: viewModel.temperature,
                                               temperatureFeelsLike: viewModel.temperatureFeelsLike)
    }

    func displayUpdateRecentSearch(viewModel: WeatherInformation.UpdateRecentSearch.ViewModel) {
        self.searchHistory = viewModel.searchHistory
        self.tableView.reloadData()
    }

    func displayError(viewModel: WeatherInformation.Error.ViewModel) {
        let alertController = UIAlertController(title: viewModel.title,
                                                message: viewModel.message,
                                                preferredStyle: .alert)

        let okAction = UIAlertAction(title: "OK", style: .cancel)
        alertController.addAction(okAction)

        self.present(alertController, animated: true, completion: nil)
    }
}

extension WeatherInformationViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.weatherInformationView.isHidden = true
        searchBar.setShowsCancelButton(true, animated: true)
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.weatherInformationView.isHidden = false
        searchBar.setShowsCancelButton(false, animated: true)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.requestWeatherData(searchWord: searchBar.text)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }

    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        guard self.hasLocationPermission() else {
            let alertController = UIAlertController(title: "Location Permission Required",
                                                    message: "Please enable location permissions in settings.",
                                                    preferredStyle: .alert)

            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            alertController.addAction(cancelAction)

            let okAction = UIAlertAction(title: "Settings", style: .default, handler: {(cAlertAction) in
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            })
            alertController.addAction(okAction)

            self.present(alertController, animated: true, completion: nil)
            return
        }

        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        self.locationManager.startUpdatingLocation()
    }

    private func hasLocationPermission() -> Bool {
        if CLLocationManager.locationServicesEnabled() {
            switch self.locationManager.authorizationStatus {
            case .restricted, .denied:
                return false
            case .notDetermined, .authorizedAlways, .authorizedWhenInUse:
                return true
            @unknown default:
                fatalError()
            }
        }
        return false
    }
}

extension WeatherInformationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Most Recent Search"
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
        let searchHistory = self.searchHistory[indexPath.row]
        let request = WeatherInformation.WeatherData.Request(searchType: .location(searchHistory.location))
        self.interactor?.requestWeatherData(request: request)
    }

    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            self.searchHistory.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            let request = WeatherInformation.UpdateRecentSearch.Request(
                searchHistory: self.searchHistory,
                shouldReloadTableView: false
            )
            self.interactor?.requestUpdateRecentSearch(request: request)
        case .insert, .none:
            break
        @unknown default:
            fatalError()
        }
    }
}

extension WeatherInformationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchHistory.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.selectionStyle = .none
        let searchHistory = self.searchHistory[indexPath.row]
        let cityName = searchHistory.cityName
        let latitude = searchHistory.location.latitude
        let longitude = searchHistory.location.longitude
        cell.backgroundColor = themeManager.currentTheme.backgroundColor
        cell.textLabel?.text = "\(cityName) (\(latitude), \(longitude))"
        cell.textLabel?.textColor = themeManager.currentTheme.textColor
        return cell
    }
}

extension WeatherInformationViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue = manager.location?.coordinate else { return }
        self.view.endEditing(true)
        manager.stopUpdatingLocation()
        let request = WeatherInformation.WeatherData.Request(
            searchType: .location(Location(locValue.latitude,
                                           locValue.longitude))
        )
        self.interactor?.requestWeatherData(request: request)
    }
}
