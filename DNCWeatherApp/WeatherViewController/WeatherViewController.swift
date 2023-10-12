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
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .white
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicator
    }()
    
    // MARK: - Lifecycle Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.startAnimating()
        loadDataFromStorage()
        setupLocation()
        setupViews()
        setConstraints()
        setDelegate()
    }
    
    // MARK: - Fetching functions

    @MainActor
    func fetchForecastResult() async {
        
        do {
            async let forecastResult: ForecastResult = try await apiService.getJSON(urlString: "http://api.weatherapi.com/v1/forecast.json?q=\(lat),\(lon)&days=14")
            async let currentResult: CurrentResult = try await apiService.getJSON(urlString: "http://api.weatherapi.com/v1/current.json?q=\(lat),\(lon)")
            let currentLocation = await CurrentLocation(current: try currentResult.current, location: try currentResult.location)
            self.current = .current(currentLocation)
            self.hourly = await .hourly(try forecastResult.forecast.forecastday[0].hour)
            self.forecast = await .forecast(try forecastResult.forecast.forecastday)
            self.sections = [self.current, self.hourly, self.forecast]
            self.place = try await forecastResult.location.name
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                self.activityIndicator.stopAnimating()
            }
            
            await saveDataToStorage(current: try currentResult, forecast: try forecastResult)
        } catch {
            self.activityIndicator.stopAnimating()
            self.showErrorMessage()
            
        }
    }
    
    func showErrorMessage(){
        let alert = UIAlertController(title: "Error", message: "There was a problem loading the feed, please check your connection and try again.", preferredStyle: .alert)
        
        let tryAgainAction = UIAlertAction(title: "Try Again", style: .default) {  _ in
            Task {
                await self.fetchForecastResult()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(tryAgainAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func saveDataToStorage(current: CurrentResult, forecast: ForecastResult) {
        if let currentData = try? JSONEncoder().encode(current),
           let forecastData = try? JSONEncoder().encode(forecast) {
            UserDefaults.standard.set(currentData, forKey: "currentData")
            UserDefaults.standard.set(forecastData, forKey: "forecastData")
        }
    }
    
    func loadDataFromStorage() {
        if let previousCurrentData = UserDefaults.standard.data(forKey: "currentData"),
           let previousForecastData = UserDefaults.standard.data(forKey: "forecastData") {
            let currentResult = try? JSONDecoder().decode(CurrentResult.self, from: previousCurrentData)
            let forecastResult = try? JSONDecoder().decode(ForecastResult.self, from: previousForecastData)
            
            let currentLocation = CurrentLocation(current: currentResult!.current, location: currentResult!.location)
            self.current = .current(currentLocation)
            self.hourly = .hourly(forecastResult!.forecast.forecastday[0].hour)
            self.forecast = .forecast(forecastResult!.forecast.forecastday)
            self.sections = [self.current, self.hourly, self.forecast]
            self.place = forecastResult!.location.name
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
            
        }
    }
    
    // MARK: - Setting functions
    
    private func setupActivityIndicator() {
        collectionView.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor)
        ])
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBlue
        setupActivityIndicator()
        view.addSubview(collectionView)
        collectionView.register(CurrentWeatherCell.self, forCellWithReuseIdentifier: CurrentWeatherCell.identifier)
        collectionView.register(HourlyWeatherCell.self, forCellWithReuseIdentifier: HourlyWeatherCell.identifier)
        collectionView.register(ForecastWeatherCell.self, forCellWithReuseIdentifier: ForecastWeatherCell.identifier)
        collectionView.register(HeaderSupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderSupplementaryView.identifier)
        
        collectionView.collectionViewLayout = createLayout()
        collectionView.collectionViewLayout.register(RoundedBackgroundView.self, forDecorationViewOfKind: RoundedBackgroundView.identifier)
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
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
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(140)))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(0.15), heightDimension: .fractionalHeight(0.1)), subitems: [item])
        
        let section = createLayoutSection(group: group,
                                          behavior: .continuous,
                                          interGroupSpacing: 0,
                                          supplementaryItems: [])
        section.contentInsets = .init(top: 0, leading: 0, bottom: 35, trailing: 0)
        section.decorationItems = [NSCollectionLayoutDecorationItem.background(elementKind: RoundedBackgroundView.identifier)]
        
        return section
    }
    
    private func createForecastSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50)))
        
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(1)), subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 5, leading: 0, bottom: 10, trailing: 0)
        section.boundarySupplementaryItems = [supplementaryHeaderItem()]
        section.decorationItems = [NSCollectionLayoutDecorationItem.background(elementKind: RoundedBackgroundView.identifier)]
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
