//
//  Router.swift
//  TheMovieDBTest
//
//  Created by admin on 29.07.2024.
//

import UIKit

class Coordinator {
    
    weak var navigationVC: UINavigationController?
    
    func initialViewController() -> UIViewController? {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MoviesListViewController")
        guard let popularMoviesVC = viewController as? MoviesListViewController else {
            assertionFailure("MoviesListViewController is bad configured in Main storyboard")
            return nil
        }
        let viewModel = MoviesListViewModel(moviesService: MoviesService(), router: self)
        viewModel.goToMovieDetailsScreen = {[weak self] movieId in
            self?.goToMovieDetailsScreen(movieId: movieId)
        }
        
        popularMoviesVC.moviesListVM = viewModel
        viewModel.screen = popularMoviesVC
        
        let nav = UINavigationController(rootViewController: popularMoviesVC)
        navigationVC = nav
        
        return nav
    }
    
    private func goToMovieDetailsScreen(movieId: Int) {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MoviewDetailsViewController")
        guard let movieDetailsVC = viewController as? MoviewDetailsViewController else {
            assertionFailure("MoviewDetailsViewController is bad configured in Main storyboard")
            return
        }
        let viewModel = MovieDetailsViewModel(screen: movieDetailsVC, moviesService: MoviesService(), movieId: movieId)
        movieDetailsVC.movieDetailsVM = viewModel
        navigationVC?.pushViewController(movieDetailsVC, animated: true)
    }
}
