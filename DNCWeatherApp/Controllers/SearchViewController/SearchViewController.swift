//
//  SearchViewController.swift
//  DNCWeatherApp
//
//  Created by Ilya Tovstokory on 17.10.2023.
//

import UIKit

class SearchViewController: UIViewController {
    
    let apiService = APIService.shared
    
    private let searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: SearchResultViewController())
        controller.searchBar.placeholder = "Seacrh for location"
        controller.searchBar.searchBarStyle = .minimal
        return controller
    }()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBlue
        
        title = "Search"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.tintColor = .white
        
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
    }
    
    func showErrorMessage(){
        let alert = UIAlertController(title: "Error", message: "There was a problem loading the feed, please check your connection and try again.", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
}

extension SearchViewController: UISearchResultsUpdating {
    
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        
        guard let query = searchBar.text,
              !query.trimmingCharacters(in: .whitespaces).isEmpty,
              query.trimmingCharacters(in: .whitespaces).count >= 3,
              let resultsController = searchController.searchResultsController as? SearchResultViewController else {return}
        
        Task {
            do {
                async let searchResult: [SearchResult] = try await apiService.getJSON(urlString: "http://api.weatherapi.com/v1/search.json?q=\(query)")
                resultsController.locations = try await searchResult
                DispatchQueue.main.async {
                    resultsController.tableView.reloadData()
                    resultsController.activityIndicator.stopAnimating()
                }
            } catch {
                self.showErrorMessage()
                resultsController.activityIndicator.stopAnimating()
            }
        }
    }
    
    
}
