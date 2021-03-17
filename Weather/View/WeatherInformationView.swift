//
//  WeatherInformationView.swift
//  Weather
//
//  Created by Gavin Lau on 15/3/2021.
//

import UIKit

class WeatherInformationView: UIView {

    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var weatherIconImageView: UIImageView!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var temperatureFeelsLikeLabel: UILabel!

    init() {
        super.init(frame: .zero)

        self.commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.commonInit()
    }

    private func commonInit() {
        guard let view = self.loadViewFromNib() else { return }
        view.frame = self.bounds
        self.addSubview(view)
    }

    private func loadViewFromNib() -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "WeatherInformationView", bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }

    func configView(cityName: String?,
                    iconURL: URL?,
                    weather: String?,
                    temperature: String?,
                    temperatureFeelsLike: String?) {
        self.cityNameLabel.text = cityName

        if let anIconURL = iconURL {
            self.weatherIconImageView.load(url: anIconURL)
            self.weatherIconImageView.isHidden = false
        } else {
            self.weatherIconImageView.image = nil
            self.weatherIconImageView.isHidden = true
        }

        self.weatherLabel.text = weather
        self.temperatureLabel.text = temperature
        self.temperatureFeelsLikeLabel.text = temperatureFeelsLike
    }
}
