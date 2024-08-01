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
        
        viewModel.goToPosterScrollView = { [weak self] imagePath in
            self?.goToPosterScrolLView(imagePath: imagePath)
        }
        
        viewModel.goToTrailer = { [weak self] trailerId in
            self?.playTrailer(trailerId: trailerId)
        }
        
        navigationVC?.pushViewController(movieDetailsVC, animated: true)
    }
    
    private func goToPosterScrolLView(imagePath: String) {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PosterViewController")
        guard let posterViewController = viewController as? PosterViewController else {
            assertionFailure("PosterViewController is bad configured in Main storyboard")
            return
        }
        posterViewController.imagePath = imagePath
        let navController = UINavigationController(rootViewController: posterViewController)
        navigationVC?.present(navController, animated: true)
    }
    
    private func playTrailer(trailerId: String) {
        
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "YouTubeVideoPlayerViewController")
        guard let videoPlayerVC = viewController as? YouTubeVideoPlayerViewController else {
            assertionFailure("YouTubeVideoPlayerViewController is bad configured in Main storyboard")
            return
        }
        videoPlayerVC.videoId = trailerId
        
        if let sheet = videoPlayerVC.sheetPresentationController {
            sheet.prefersGrabberVisible = true
            sheet.detents = [.large(), .medium()]
            sheet.selectedDetentIdentifier = .medium
        }
        
        navigationVC?.present(videoPlayerVC, animated: true)
    }
}
