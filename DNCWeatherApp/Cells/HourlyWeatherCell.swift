//
//  HourlyWeatherCell.swift
//  DNCWeatherApp
//
//  Created by Ilya Tovstokory on 11.10.2023.
//

import UIKit
import SDWebImage

class HourlyWeatherCell: UICollectionViewCell {
    
    static let identifier = "HourlyWeatherCell"
    
    private let weatherTimeView: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .bold)
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
    
    private let weatherTempView: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .bold)
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
        addSubview(weatherTimeView)
        addSubview(weatherImageView)
        addSubview(weatherTempView)
    }
    
    func configure(with model: Hour) {
        guard let url = URL(string: "http:" + model.condition.icon) else { return }
        
        weatherTimeView.text = model.timeEpoch.hours()
        weatherImageView.sd_setImage(with: url, completed: nil)
        weatherTempView.text = String(format: "%.0f", model.tempC.rounded()) + "°"
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            weatherTimeView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            weatherTimeView.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            weatherImageView.topAnchor.constraint(equalTo: weatherTimeView.bottomAnchor, constant: 2),
            weatherImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            weatherImageView.widthAnchor.constraint(equalToConstant: 40),
            weatherImageView.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        NSLayoutConstraint.activate([
            weatherTempView.topAnchor.constraint(equalTo: weatherImageView.bottomAnchor, constant: 2),
            weatherTempView.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
}
