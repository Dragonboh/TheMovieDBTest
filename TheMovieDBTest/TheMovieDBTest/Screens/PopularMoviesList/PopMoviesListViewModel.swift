//
//  MoviesListViewModel.swift
//  TheMovieDBTest
//
//  Created by admin on 28.07.2024.
//

import Foundation

protocol PopMoviesListViewModelProtocol {
    func fetchInitialData()
    func fetchMoreData()
    func searchMovie(title: String)
    func didSelectRowAt(_ indexPath: IndexPath)
    func searchBarCancelButtonClicked()
}

class PopMoviesListViewModel: PopMoviesListViewModelProtocol {
    
    private let moviesService: MoviesProvidable
    private let router: Coordinator
    
    private var initialTotalPages = 0
    private var searchTotalPages = 0
    private var initialMovies: [MovieModel] = []
    private var isSearchingMode = false
    private var searchQuery = ""
    private var initialLoading = true
    
    weak var screen: MovieListScreenProtocol?
    
    var goToMovieDetailsScreen: ((Int) -> Void)?
    var currentSortOption: SortOption = .popularity
    var filteredMovies: [MovieModel] = []
    
    init(moviesService: MoviesProvidable, router: Coordinator) {
        self.moviesService = moviesService
        self.router = router
    }

    // MARK: - Public API
    
    func fetchInitialData() {
        screen?.updateState(state: .initialDataLoadingStart)
        initialLoading = true
        initialTotalPages = 0
        fetchData()
    }
    
    func fetchMoreData() {
        screen?.updateState(state: .moreDataLoadingStart)
        initialLoading = false
        if isSearchingMode {
            searchData()
        } else {
            fetchData()
        }
    }
    
    func searchMovie(title: String) {
        screen?.updateState(state: .initialDataLoadingStart)
        isSearchingMode = true
        initialLoading = true
        searchQuery = title
        searchTotalPages = 0
        filteredMovies = []
        searchData()
    }
    
    func didSelectRowAt(_ indexPath: IndexPath) {
        let movie = filteredMovies[indexPath.row]
        goToMovieDetailsScreen?(movie.id)
    }
    
    func searchBarCancelButtonClicked() {
        filteredMovies = initialMovies
        isSearchingMode = false
        searchQuery = ""
        searchTotalPages = 0
        screen?.updateState(state: .reloadData)
    }
    
//    func updateSearchResults() {
//        filteredMovies = []
//        screen?.updateState(state: .reloadData)
//    }
    
    // MARK: - Private functions
    
//    private func fetchInitialData() {
//        screen?.updateState(state: .initialDataLoadingStart)
//        initialLoading = true
//        initialTotalPages = 0
//        fetchData()
//    }
//    
//    private func fetchSearchInitialData() {
//        screen?.updateState(state: .initialDataLoadingStart)
//        isSearchingMode = true
//        initialLoading = true
//        searchQuery = title
//        searchTotalPages = 0
//        filteredMovies = []
//        searchData()
//    }
    
    private func fetchData() {
        let page = initialTotalPages + 1
        moviesService.fetchMovies(page: page, sortBy: currentSortOption) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let moviesArray):
                    self.initialTotalPages = page
                    
                    if self.initialLoading {
                        self.initialMovies = moviesArray
                        self.filteredMovies = moviesArray
                        self.screen?.updateState(state: .initialDataLoadingFinished)
                    } else {
                        self.initialMovies.append(contentsOf: moviesArray)
                        self.filteredMovies.append(contentsOf: moviesArray)
                        self.screen?.updateState(state: .moreDataLoadedFinished)
                    }
                case .failure(let error):
                    self.screen?.updateState(state: .error(error))
                }
            }
        }
    }
    
    private func searchData() {
        let page = searchTotalPages + 1
        moviesService.searchMovieByTitle(searchQuery, page: page) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let moviesArray):
                    self.searchTotalPages = page
                    self.filteredMovies.append(contentsOf: moviesArray)
                    if self.initialLoading {
                        self.screen?.updateState(state: .initialDataLoadingFinished)
                    } else {
                        self.screen?.updateState(state: .moreDataLoadedFinished)
                    }
                case .failure(let error):
                    print("DEBUG: error in searching data for title \(self.searchQuery), error: \(error.errorMessage)")
                    self.filterMovie(title: self.searchQuery)
                    switch error {
                    case .error(_):
                        self.screen?.updateState(state: .error(error))
                    case .noInternetConnection:
                        self.screen?.updateState(state: .reloadData)
                        self.screen?.updateState(state: .initialDataLoadingFinished)
                        self.screen?.updateState(state: .error(error))
                    }
                }
            }
        }
    }
    
    private func filterMovie(title: String) {
        filteredMovies = initialMovies.filter({ movie in
            movie.title?.lowercased().contains(title.lowercased()) ?? false
        })
    }
}
