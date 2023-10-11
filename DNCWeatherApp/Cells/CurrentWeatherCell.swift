//
//  CurrentWeatherCell.swift
//  DNCWeatherApp
//
//  Created by Ilya Tovstokory on 10.10.2023.
//

import UIKit

class CurrentWeatherCell: UICollectionViewCell {
    
    static let identifier = "CurrentWeatherCell"
    
    private let weatherPlaceView: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 45, weight: .bold)
        return label
    }()
    
    private let weatherDegreesView: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 70, weight: .bold)
        return label
    }()
    
    private let weatherConditionView: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 25, weight: .bold)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(white: 1.0, alpha: 0.6)
        setupView()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        backgroundColor = .none
        layer.cornerRadius = 10
        addSubview(weatherPlaceView)
        addSubview(weatherDegreesView)
        addSubview(weatherConditionView)
    }
    
    func configure(with current: CurrentLocation) {
        weatherPlaceView.text = current.location.name
        weatherDegreesView.text = String(current.current.tempC) + "°"
        weatherConditionView.text = current.current.condition.text
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            weatherPlaceView.topAnchor.constraint(equalTo: topAnchor, constant: 25),
            weatherPlaceView.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            weatherDegreesView.topAnchor.constraint(equalTo: weatherPlaceView.bottomAnchor, constant: 5),
            weatherDegreesView.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            weatherConditionView.topAnchor.constraint(equalTo: weatherDegreesView.bottomAnchor, constant: 5),
            weatherConditionView.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
}
