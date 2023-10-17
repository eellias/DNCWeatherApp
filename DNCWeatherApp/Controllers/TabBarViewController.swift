//
//  TabBarViewController.swift
//  DNCWeatherApp
//
//  Created by Ilya Tovstokory on 17.10.2023.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let vc1 = UINavigationController(rootViewController: WeatherViewController())
        let vc2 = UINavigationController(rootViewController: SearchViewController())
        
        vc1.tabBarItem.image = UIImage(systemName: "cloud.sun")
        vc2.tabBarItem.image = UIImage(systemName: "magnifyingglass")
        
        vc1.title = "Forecast"
        vc2.title = "Search"
        
        tabBar.tintColor = .white
        tabBar.barTintColor = .systemBlue
        
        setViewControllers([vc1, vc2], animated: true)
    }

}
