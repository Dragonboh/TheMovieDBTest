//
//  MoviesListViewModel.swift
//  TheMovieDBTest
//
//  Created by admin on 28.07.2024.
//

import Foundation

class MoviesListViewModel {
    
    private let moviesService = MoviesService()
    
    func fetchMoviesList(complition: @escaping ([MovieModel]) -> Void) {
        moviesService.fetchPopularMovies(complition: complition)
    }
}
