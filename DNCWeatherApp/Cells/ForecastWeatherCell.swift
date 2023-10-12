//
//  ForecastWeatherCell.swift
//  DNCWeatherApp
//
//  Created by Ilya Tovstokory on 11.10.2023.
//

import UIKit
import SDWebImage

class ForecastWeatherCell: UICollectionViewCell {
    
    static let identifier = "ForecastWeatherCell"
    
    private let weatherDayView: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .white
        return label
    }()
    
    private let weatherImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let weatherMinTempView: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .white
        return label
    }()
    
    private let weatherMaxTempView: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .white
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        addSubview(weatherDayView)
        addSubview(weatherImageView)
        addSubview(weatherMinTempView)
        addSubview(weatherMaxTempView)
    }
    
    func configure(with model: Forecastday) {
        guard let url = URL(string: "http:" + model.day.condition.icon) else { return }
        
        weatherDayView.text = String(model.dateEpoch.dayOfWeek())
        weatherImageView.sd_setImage(with: url, completed: nil)
        weatherMinTempView.text = String(format: "%.0f", model.day.mintempC.rounded()) + "°"
        weatherMaxTempView.text = String(format: "%.0f", model.day.maxtempC.rounded()) + "°"
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            weatherDayView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            weatherDayView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            weatherImageView.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            weatherImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
            weatherImageView.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            weatherMaxTempView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            weatherMaxTempView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            weatherMinTempView.trailingAnchor.constraint(equalTo: weatherMaxTempView.leadingAnchor, constant: -50),
            weatherMinTempView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
