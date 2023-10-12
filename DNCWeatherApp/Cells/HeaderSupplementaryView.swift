//
//  HeaderSupplementaryView.swift
//  DNCWeatherApp
//
//  Created by Ilya Tovstokory on 11.10.2023.
//

import UIKit

class HeaderSupplementaryView: UICollectionReusableView {
    
    static let identifier = "HeaderSupplementaryView"
    
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(headerLabel)
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(sectionName: String) {
        headerLabel.text = sectionName
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            headerLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            headerLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10)
        ])
    }
}
