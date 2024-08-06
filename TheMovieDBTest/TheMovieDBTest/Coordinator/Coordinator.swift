//
//  Router.swift
//  TheMovieDBTest
//
//  Created by admin on 29.07.2024.
//

import UIKit
import OSLog

class Coordinator {
    
    weak var rootViewController: UINavigationController?
    private let storyboard = UIStoryboard(name: "Main", bundle: nil)
    
    func initialViewController() -> UIViewController? {
        let vc = createPopMoviesListViewController()
        let nav = UINavigationController(rootViewController: vc)
        rootViewController = nav
        return nav
    }

    private func goToMovieDetailsScreen(movieId: Int) {
        let vc = createMovieDetailsViewController(movieId: movieId)
        rootViewController?.pushViewController(vc, animated: true)
    }
    
    private func playTrailer(trailerId: String) {
        let vc = createTrailerViewController(videoId: trailerId)
        rootViewController?.present(vc, animated: true)
    }
    
    private func goToPosterScrolLView(imagePath: String) {
        let navController = UINavigationController(rootViewController: PosterViewController(imagePath: imagePath))
        rootViewController?.present(navController, animated: true)
    }
}

private extension Coordinator {
    private func createPopMoviesListViewController() -> PopMoviesViewController {
        let viewModel = PopMoviesListViewModel(moviesService: MoviesService(), router: self)
        viewModel.goToMovieDetailsScreen = {[weak self] movieId in
            self?.goToMovieDetailsScreen(movieId: movieId)
        }
        
        let popularMoviesVC = storyboard.instantiateViewController(identifier: String(describing: PopMoviesViewController.self)) { coder in
            PopMoviesViewController(coder: coder, viewModel: viewModel)
        }
            
        viewModel.screen = popularMoviesVC
        
        return popularMoviesVC
    }
    
    private func createMovieDetailsViewController(movieId: Int) -> MoviewDetailsViewController {
        
        let viewModel = MovieDetailsViewModel(moviesService: MoviesService(), movieId: movieId)
        viewModel.goToPosterScrollView = { [weak self] imagePath in
            self?.goToPosterScrolLView(imagePath: imagePath)
        }
        
        viewModel.goToTrailer = { [weak self] trailerId in
            self?.playTrailer(trailerId: trailerId)
        }

        let moviewDetailsVC = storyboard.instantiateViewController(identifier: String(describing: MoviewDetailsViewController.self)) { coder in
            MoviewDetailsViewController(coder: coder, viewModel: viewModel)
        }
        
        viewModel.screen = moviewDetailsVC
        
        return moviewDetailsVC
    }
    
    private func createTrailerViewController(videoId: String) -> YouTubeVideoPlayerViewController {
        let trailerVC = storyboard.instantiateViewController(identifier: String(describing: YouTubeVideoPlayerViewController.self)) { coder in
            YouTubeVideoPlayerViewController(coder: coder, videoId: videoId)
        }
         
        return trailerVC
    }
}

