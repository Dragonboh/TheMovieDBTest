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
    
    private var initialTotalPages = 0
    private var searchTotalPages = 0
    private var initialMovies: [MovieModel] = []
    private var isSearching = false
    private var searchQuery = ""
    
    weak var screen: MovieListScreenProtocol?
    
    var goToMovieDetailsScreen: ((Int) -> Void)?
    var currentSortOption: SortOption = .popularity
    var filteredMovies: [MovieModel] = []
    
    init(moviesService: MoviesService, router: Coordinator) {
        self.moviesService = moviesService
        self.router = router
    }

    func fetchInitialData() {
        screen?.updateState(state: .initialDataLoadingStart)
        fetchData(page: 1) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let moviesArray):
                    self.initialMovies = moviesArray
                    self.filteredMovies = moviesArray
                    self.screen?.updateState(state: .initialDataLoadingFinished)
                case .failure(let failure):
                    self.screen?.updateState(state: .error(failure.errorMessage))
                }
            }
        }
    }
    
    func fetchMoreData() {
        screen?.updateState(state: .moreDataLoadingStart)
        if isSearching {
            seachData()
            return
        }
        fetchData(page: initialTotalPages + 1) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let moreData):
                    let startIndex = self.filteredMovies.count
                    let endIndex = self.filteredMovies.count + moreData.count
                    let indices = Array(startIndex..<endIndex).compactMap {
                        IndexPath(row: $0, section: 0)
                    }
                    self.initialMovies.append(contentsOf: moreData)
                    self.filteredMovies.append(contentsOf: moreData)
                    self.screen?.updateState(state: .moreDataLoadedFinished(indices))
                case .failure(let failure):
                    self.screen?.updateState(state: .error(failure.errorMessage))
                }
            }
        }
    }
    
    func didSelectRowAt(_ indexPath: IndexPath) {
        let movie = filteredMovies[indexPath.row]
        goToMovieDetailsScreen?(movie.id)
    }
    
    func updateSearchResults() {
        filteredMovies = []
        screen?.updateState(state: .reloadData)
    }
    
    func searchBarCancelButtonClicked() {
        filteredMovies = initialMovies
        screen?.updateState(state: .reloadData)
    }
    
    func searchMovie(title: String) {
        isSearching = true
        searchQuery = title
        searchTotalPages = 0
        screen?.updateState(state: .initialDataLoadingStart)
        seachData()
    }
    
    private func filterMovie(title: String) {
        filteredMovies = initialMovies.filter({ movie in
            movie.title?.lowercased().contains(title.lowercased()) ?? false
        })
    }
    
    private func fetchData(page: Int, complition: @escaping (Result<[MovieModel], CustomError>) -> Void) {
        moviesService.fetchMovies(page: page, sortBy: currentSortOption) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let moviesArray):
                initialTotalPages = page
                complition(.success(moviesArray))
            case .failure(let errorMessage):
                print("DEBUG: error in fetching data for popular movies list: \(errorMessage.errorMessage)")
                complition(.failure(.error(errorMessage.errorMessage)))
                return
            }
        }
    }
    
    private func seachData() {
        moviesService.searchMovieByTitle(searchQuery, page: searchTotalPages + 1) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let moviesArray):
                    if self.searchTotalPages > 0 {
                        let startIndex = self.filteredMovies.count
                        let endIndex = self.filteredMovies.count + moviesArray.count
                        let indices = Array(startIndex..<endIndex).compactMap {
                            IndexPath(row: $0, section: 0)
                        }
                        
                        self.filteredMovies.append(contentsOf: moviesArray)
                        self.screen?.updateState(state: .moreDataLoadedFinished(indices))
                    }
                    self.searchTotalPages += 1
                    self.filteredMovies = moviesArray
                    self.screen?.updateState(state: .initialDataLoadingFinished)
                case .failure(let errorMessage):
                    print("DEBUG: error in fetching data for popular movies list: \(errorMessage.errorMessage)")
                    self.filterMovie(title: self.searchQuery)
                    self.screen?.updateState(state: .error(errorMessage.errorMessage))
                    self.screen?.updateState(state: .reloadData)
                    return
                }
            }
        }
    }
}
