//
//  Router.swift
//  TheMovieDBTest
//
//  Created by admin on 29.07.2024.
//

import UIKit

class Router {
    
    weak var navigationVC: UINavigationController?
    
    func initialViewController() -> UIViewController? {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MoviesListViewController")
        guard let popularMoviesVC = viewController as? MoviesListViewController else {
            assertionFailure("MoviesListViewController is bad configured in Main storyboard")
            return nil
        }
        let viewModel = MoviesListViewModel(moviesService: MoviesService(), router: self)
        popularMoviesVC.moviesListVM = viewModel
        let nav = UINavigationController(rootViewController: popularMoviesVC)
        navigationVC = nav
        
        return nav
    }
}
