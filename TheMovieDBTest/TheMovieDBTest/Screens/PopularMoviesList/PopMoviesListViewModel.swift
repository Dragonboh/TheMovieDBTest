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
    private var initialSearching = true
    
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
        fetchData()
    }
    
    func fetchMoreData() {
        screen?.updateState(state: .moreDataLoadingStart)
        
        if isSearchingMode {
            initialSearching = false
            searchData()
        } else {
            initialLoading = false
            fetchData()
        }
    }
    
    func searchMovie(title: String) {
        screen?.updateState(state: .initialDataLoadingStart)
        isSearchingMode = true
        initialSearching = true
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
    
    // MARK: - Private functions
    
    private func fetchData() {
        let page = getPage() + 1
        moviesService.fetchMovies(page: page, sortBy: currentSortOption) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let moviesArray):
                    self.initialTotalPages = page
                    self.initialDataLoadSuccess(moviesArray)
                case .failure(let error):
                    if self.initialLoading {
                        self.screen?.updateState(state: .initialDataLoadingFailed(error))
                    } else {
                        self.screen?.updateState(state: .moreDataLoadingFailed(error))
                    }
                }
            }
        }
    }
    
    private func searchData() {
        let page = getSearchPage() + 1
        moviesService.searchMovieByTitle(searchQuery, page: page) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let moviesArray):
                    self.searchTotalPages = page
                    self.filteredMovies.append(contentsOf: moviesArray)
                    if self.initialSearching {
                        self.screen?.updateState(state: .initialDataLoadingFinished)
                    } else {
                        self.screen?.updateState(state: .moreDataLoadingFinished)
                    }
                case .failure(let error):
                    self.handleSearchingError(error)
                }
            }
        }
    }
    
    private func filterMovie(title: String) {
        filteredMovies = initialMovies.filter({ movie in
            movie.title?.lowercased().contains(title.lowercased()) ?? false
        })
    }
    
    private func getPage() -> Int {
        if initialLoading {
            return 0
        } else {
            return initialTotalPages
        }
    }
    
    private func getSearchPage() -> Int {
        if initialSearching {
            return 0
        } else {
            return searchTotalPages
        }
    }
    
    private func handleSearchingError(_ error: CustomError) {
        print("DEBUG: error in searching data for title \(self.searchQuery), error: \(error.errorMessage)")
        switch error {
        case .error(_):
            if initialSearching {
                screen?.updateState(state: .initialDataLoadingFailed(error))
            } else {
                screen?.updateState(state: .moreDataLoadingFailed(error))
            }
        case .noInternetConnection:
            print("DEBUG: noInternetConnection")
            if initialSearching {
                filterMovie(title: self.searchQuery)
                screen?.updateState(state: .offlineSearch(error))
            } else {
                screen?.updateState(state: .moreDataLoadingFailed(error))
            }
        }
    }
    
    private func initialDataLoadSuccess(_ movies: [MovieModel]) {
        if initialLoading {
            initialMovies = movies
            filteredMovies = movies
            screen?.updateState(state: .initialDataLoadingFinished)
        } else {
            initialMovies.append(contentsOf: movies)
            filteredMovies.append(contentsOf: movies)
            screen?.updateState(state: .moreDataLoadingFinished)
        }
    }
}
