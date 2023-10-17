//
//  SearchResultViewController.swift
//  DNCWeatherApp
//
//  Created by Ilya Tovstokory on 17.10.2023.
//

import UIKit

class SearchResultViewController: UIViewController {
    public var locations: [SearchResult] = [SearchResult]()
    
    public let tableView: UITableView = {
        let table = UITableView(frame: .zero)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = .systemBlue
        table.showsVerticalScrollIndicator = false
        return table
    }()
    
    public let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .white
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicator
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimating()
        setupViews()
        setConstraints()
        setDelegate()
    }
    
    // MARK: - Setting functions
    
    private func setupActivityIndicator() {
        tableView.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: tableView.centerYAnchor)
        ])
        tableView.register(SearchResultCell.self, forCellReuseIdentifier: SearchResultCell.identifier)
    }
    
    private func setupViews() {
        setupActivityIndicator()
        view.addSubview(tableView)
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ])
    }
    
    private func setDelegate() {
        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension SearchResultViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultCell.identifier, for: indexPath) as? SearchResultCell else { return UITableViewCell()}
        
        let location = locations[indexPath.row]
        cell.configure(with: location)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedLocation = locations[indexPath.row]
        let weatherVC = WeatherViewController()
        weatherVC.lat = String(selectedLocation.lat)
        weatherVC.lon = String(selectedLocation.lon)
        weatherVC.isLocationSetFromSearch = true
        present(weatherVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
