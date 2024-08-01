//
//  MovieDetailsViewModel.swift
//  TheMovieDBTest
//
//  Created by admin on 31.07.2024.
//

import Foundation

class MovieDetailsViewModel {
    private let moviesService: MoviesService
    private let movieId: Int
    
    weak var screen: MoviewDetailsScreenProtocol?
    var movieDetails: MovieDetails = MovieDetails.movieDetailsSample
    
    init(screen: MoviewDetailsScreenProtocol? = nil, moviesService: MoviesService, movieId: Int) {
        self.screen = screen
        self.moviesService = moviesService
        self.movieId = movieId
    }
    
    func fetchMovieDetails() {
        screen?.updateState(state: .loadingStart)
        
        moviesService.fetchMovieDetailsAppendVideos(movieId: movieId) { result in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                switch result {
                case .success(let newMovieDetails):
                    movieDetails = newMovieDetails
                    screen?.updateState(state: .loadingFinished)
                case .failure(let errorMessage):
                    screen?.updateState(state: .error(errorMessage.errorMessage))
                    print(errorMessage)
                }
            }
        }
    }
    
    func didSelectRowAt(_ indexPath: IndexPath) {
        guard indexPath.row == 0 else { return }
    }
}
