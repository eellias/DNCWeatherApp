//
//  ViewController.swift
//  DNCWeatherApp
//
//  Created by Ilya Tovstokory on 05.10.2023.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {
    
    // MARK: - Properties
    var currentResult: CurrentResult?
    
    private var current: ListSection?
    private var hourly: ListSection?
    private var forecast: ListSection?
    
    private var sections: [ListSection?] = []
    
    let apiService = APIService.shared
    
    let locationManager = CLLocationManager()
    
    var currentLocation: CLLocation?
    
    var place: String = ""
    
    var lat: String = ""
    var lon: String = ""
    
    private let collectionView: UICollectionView = {
        let collectionViewLayout = UICollectionViewLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBlue
        collectionView.bounces = false
        return collectionView
    }()
    
    // MARK: - Lifecycle Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchForecastResult()
        setupViews()
        setConstraints()
        setDelegate()
    }
    
    // MARK: - Fetching functions

    func fetchCurrentResult() {
        
        apiService.getJSON(urlString: "http://api.weatherapi.com/v1/current.json?q=\(lat),\(lon)") { (result: Result<CurrentResult, APIError>) in
            switch result {
            case .success(let currentResult):
                DispatchQueue.main.async {
                    self.currentResult = currentResult
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func fetchForecastResult() {
        
        // TODO: [weak self]
        
        apiService.getJSON(urlString: "http://api.weatherapi.com/v1/forecast.json?q=Kharkiv&days=3") { (result: Result<ForecastResult, APIError>) in
            switch result {
            case .success(let forecastResult):
                DispatchQueue.main.async {
                    let currentLocation = CurrentLocation(current: forecastResult.current, location: forecastResult.location)
                    self.current = .current(currentLocation)
                    self.hourly = .hourly(forecastResult.forecast.forecastday[0].hour)
                    self.forecast = .forecast(forecastResult.forecast.forecastday)
                    self.sections = [self.current, self.hourly, self.forecast]
                    self.place = forecastResult.location.name
                    self.collectionView.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Setting functions
    
    private func setupViews() {
        view.backgroundColor = .systemBlue
        title = "Weather"
        view.addSubview(collectionView)
        collectionView.register(CurrentWeatherCell.self, forCellWithReuseIdentifier: CurrentWeatherCell.identifier)
        collectionView.register(HourlyWeatherCell.self, forCellWithReuseIdentifier: HourlyWeatherCell.identifier)
        collectionView.register(ForecastWeatherCell.self, forCellWithReuseIdentifier: ForecastWeatherCell.identifier)
        collectionView.register(HeaderSupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderSupplementaryView.identifier)
        
        collectionView.collectionViewLayout = createLayout()
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ])
    }
    
    private func setDelegate() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
}

// MARK: - Layout creating functions

extension WeatherViewController {
    private func createLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
            guard let self = self else { return nil }
            let section = self.sections[sectionIndex]
            switch section {
            case .current(_):
                return self.createCurrentSection()
            case .hourly(_):
                return self.createHourlySection()
            case .forecast(_):
                return self.createForecastSection()
            case .none:
                return self.createEmptySection()
            }
        }
    }
    
    private func createEmptySection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        return section
    }
    
    private func createLayoutSection(group: NSCollectionLayoutGroup,
                                     behavior: UICollectionLayoutSectionOrthogonalScrollingBehavior,
                                     interGroupSpacing: CGFloat,
                                     supplementaryItems: [NSCollectionLayoutBoundarySupplementaryItem]) -> NSCollectionLayoutSection {
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = behavior
        section.interGroupSpacing = interGroupSpacing
        section.boundarySupplementaryItems = supplementaryItems
        
        return section
    }
    
    private func createCurrentSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.4)), subitems: [item])
        
        let section = createLayoutSection(group: group,
                                          behavior: .none,
                                          interGroupSpacing: 0, 
                                          supplementaryItems: [])
        return section
    }
    
    private func createHourlySection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(90)))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(0.15), heightDimension: .fractionalHeight(0.1)), subitems: [item])
        
        let section = createLayoutSection(group: group,
                                          behavior: .continuous,
                                          interGroupSpacing: 0,
                                          supplementaryItems: [])
        section.contentInsets = .init(top: 0, leading: 10, bottom: 10, trailing: 10)
        return section
    }
    
    private func createForecastSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50)))
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(1)), subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 5, leading: 10, bottom: 0, trailing: 10)
        section.boundarySupplementaryItems = [supplementaryHeaderItem()]
        return section
    }
    
    private func supplementaryHeaderItem() -> NSCollectionLayoutBoundarySupplementaryItem {
        .init(layoutSize: .init(widthDimension: .fractionalWidth(1),
                                heightDimension: .estimated(30)), 
                                elementKind: UICollectionView.elementKindSectionHeader,
                                alignment: .top)
    }
}

// MARK: - UICollectionViewDelegate functions

extension WeatherViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections[section]!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch sections[indexPath.section] {
        case .current(let current):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CurrentWeatherCell.identifier, for: indexPath) as? CurrentWeatherCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: current)
            return cell
        case .hourly(let hour):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HourlyWeatherCell.identifier, for: indexPath) as? HourlyWeatherCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: hour[indexPath.row])
            return cell
        case .forecast(let forecast):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ForecastWeatherCell.identifier, for: indexPath) as? ForecastWeatherCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: forecast[indexPath.row])
            return cell
        case .none:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderSupplementaryView.identifier, for: indexPath) as! HeaderSupplementaryView
            header.configure(sectionName: sections[indexPath.section]!.title)
            return header
        default:
            return UICollectionReusableView()
        }
    }
}
