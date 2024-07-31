//
//  MoviesListViewModel.swift
//  TheMovieDBTest
//
//  Created by admin on 28.07.2024.
//

import Foundation

class MoviesListViewModel {
    
    private let moviesService: MoviesService
    private let router: Coordinator
    
    private var totalPagesDownloaded = 0
    
    weak var screen: MovieListScreenProtocol?
    
    var goToMovieDetailsScreen: ((Int) -> Void)?
    var currentSortOption: SortOption = .popularity
    var movies: [MovieModel] = []
    
    init(moviesService: MoviesService, router: Coordinator) {
        self.moviesService = moviesService
        self.router = router
    }

    func fetchInitialData() {
        movies = []
        screen?.updateState(state: .initialDataLoadingStart)
        fetchData(page: 1) { [weak self] result in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                switch result {
                case .success(let moviesArray):
                    movies = moviesArray
                    screen?.updateState(state: .initialDataLoadingFinished)
                case .failure(let failure):
                    screen?.updateState(state: .error(failure.errorMessage))
                }
            }
        }
    }
    
    func fetchMoreData() {
        screen?.updateState(state: .moreDataLoadingStart)
        fetchData(page: totalPagesDownloaded + 1) { [weak self] result in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                switch result {
                case .success(let moreData):
                    let startIndex = movies.count
                    let endIndex = movies.count + moreData.count
                    let indices = Array(startIndex..<endIndex).compactMap {
                        IndexPath(row: $0, section: 0)
                    }
                    movies.append(contentsOf: moreData)
                    screen?.updateState(state: .moreDataLoadedFinished(indices))
                case .failure(let failure):
                    screen?.updateState(state: .error(failure.errorMessage))
                }
            }
        }
    }
    
    func didSelectRowAt(_ indexPath: IndexPath) {
        let movie = movies[indexPath.row]
        goToMovieDetailsScreen?(movie.id)
    }
    
    private func fetchData(page: Int, complition: @escaping (Result<[MovieModel], CustomError>) -> Void) {
        moviesService.fetchPopularMovies(page: page, sortBy: currentSortOption) { [weak self] data, errorMessage in
            guard let self = self else { return }
            
            if let errorMessage = errorMessage {
                print("DEBUG: error in fetching data for popular movies list: \(errorMessage)")
                complition(.failure(.error(errorMessage)))
                return
            }
            
            guard let moviesArray = data else { return }
            totalPagesDownloaded = page
            complition(.success(moviesArray))
        }
    }
}
