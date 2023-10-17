//
//  SearchResultCell.swift
//  DNCWeatherApp
//
//  Created by Ilya Tovstokory on 17.10.2023.
//

import UIKit

class SearchResultCell: UITableViewCell {

    static let identifier = "SearchResultCell"
    
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .white
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        setConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupView() {
        backgroundColor = .systemBlue
        addSubview(locationLabel)
    }
    
    func configure(with model: SearchResult) {
        locationLabel.text = "\(model.name), \(model.region), \(model.country)"
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            locationLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            locationLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            locationLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
