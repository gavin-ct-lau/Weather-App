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
}

class WeatherInformationViewController: UIViewController, WeatherInformationDisplayLogic {
    var interactor: WeatherInformationBusinessLogic?
    var router: (WeatherInformationRoutingLogic & WeatherInformationDataPassing)?

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    let locationManager = CLLocationManager()

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var weatherInformationView: WeatherInformationView!

    var searchHistory: [(cityName: String,
                         location: Location)] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.interactor?.requestSetupView(request: WeatherInformation.SetupView.Request())
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
        if CLLocationManager.locationServicesEnabled() {
            switch self.locationManager.authorizationStatus {
            //check if services disallowed for this app particularly
            case .restricted, .denied:
                let accessAlert = UIAlertController(
                    title: "Location Services Disabled",
                    message: "You need to enable location services in settings.",
                    preferredStyle: .alert)

                accessAlert.addAction(UIAlertAction(title: "Okay!",
                                                    style: .default,
                                                    handler: { action in
                                                        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                                                        UIApplication.shared.open(url,
                                                                                  options: [:],
                                                                                  completionHandler: nil)
                                                    }))

                self.present(accessAlert, animated: true, completion: nil)
            case .authorizedAlways, .authorizedWhenInUse:
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                locationManager.startUpdatingLocation()
            case .notDetermined:
                self.locationManager.requestAlwaysAuthorization()
                self.locationManager.requestWhenInUseAuthorization()
            @unknown default:
                break
            }
        }
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

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            self.searchHistory.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            let request = WeatherInformation.UpdateRecentSearch.Request(searchHistory: self.searchHistory, shouldReloadTableView: false)
            self.interactor?.requestUpdateRecentSearch(request: request)
        case .insert, .none:
            break
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
        cell.textLabel?.text = "\(cityName) (\(latitude), \(longitude))"
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
