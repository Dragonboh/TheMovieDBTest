//
//  MoviesListViewModel.swift
//  TheMovieDBTest
//
//  Created by admin on 28.07.2024.
//

import Foundation

class MoviesListViewModel {
    
    private let moviesService: MoviesService
    private let router: Router
    
    private var totalPagesDownloaded = 0
    
    var movies: [MovieModel] = []
    
    init(moviesService: MoviesService, router: Router) {
        self.moviesService = moviesService
        self.router = router
    }
    
    func fetchInitialData(complition: @escaping (String?) -> Void) {
        movies = []
        fetchData(page: 1) { [weak self] moviesArray, errorMessage in
            guard let self = self else { return }
            if let errorMessage = errorMessage {
                complition(errorMessage)
            }
            guard let moviesArray = moviesArray else { return }
            movies.append(contentsOf: moviesArray)
            complition(nil)
        }
    }
    
    func fetchMoreData(complition: @escaping ([IndexPath]?, String?) -> Void) {
        fetchData(page: totalPagesDownloaded + 1) {[weak self] moviesArray, errorMessage in
            guard let self = self else { return }
            if let errorMessage = errorMessage {
                complition(nil, errorMessage)
            }
            guard let moviesArray = moviesArray else { return }
            let startIndex = movies.count
            let endIndex = movies.count + moviesArray.count
            let indices = Array(startIndex..<endIndex).compactMap {
                IndexPath(row: $0, section: 0)
            }
            movies.append(contentsOf: moviesArray)
            complition(indices, nil)
        }
    }
    
    private func fetchData(page: Int, complition: @escaping ([MovieModel]?, String?) -> Void) {
        moviesService.fetchPopularMovies(page: page) { [weak self] data, errorMessage in
            guard let self = self else { return }
            
            if let errorMessage = errorMessage {
                print("DEBUG: error in fetching data for popular movies list: \(errorMessage)")
                complition(nil, errorMessage)
                return
            }
            
            guard let moviesArray = data else { return }
            totalPagesDownloaded = page
            complition(moviesArray, nil)
        }
    }
}
