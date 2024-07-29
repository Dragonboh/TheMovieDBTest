//
//  MoviesListViewModel.swift
//  TheMovieDBTest
//
//  Created by admin on 28.07.2024.
//

import Foundation

class MoviesListViewModel {
    
    private let moviesService = MoviesService()
    
    func fetchMoviesList(page: Int, complition: @escaping ([MovieModel]?, String?) -> Void) {
        moviesService.fetchPopularMovies(page: page, complition: complition)
    }
}
