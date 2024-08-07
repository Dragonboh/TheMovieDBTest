//
//  MoviesListViewModel.swift
//  TheMovieDBTest
//
//  Created by admin on 28.07.2024.
//

import Foundation
import OrderedCollections

protocol PopMoviesListPresenterProtocol: AnyObject {
    
    var isSearchingMode: Bool { get set }
    var isFetchingMoreData: Bool { get set }
    var isSearchingOffline: Bool { get set }
    
    func fetchInitialData()
    func fetchMoreData()
    func searchMovie(title: String)
    func didSelectMovieAt(_ indexPath: IndexPath)
    func searchBarCancelButtonClicked()
}

class PopMoviesListPresenter: PopMoviesListPresenterProtocol {
    
    private let moviesService: MoviesProvidable
    private let router: Coordinator
    
    private var initialTotalPages = 0
    private var searchTotalPages = 0
    private var initialMovies: OrderedSet<MovieModel> = []
    
    private var searchQuery = ""
    private var initialLoading = true
    private var initialSearching = true
    
    weak var view: MovieListViewProtocol?
    
    var goToMovieDetailsScreen: ((Int) -> Void)?
    var currentSortOption: SortOption = .popularity
    var filteredMovies: OrderedSet<MovieModel> = []
    
    var isSearchingMode = false
    var isFetchingMoreData = false
    var isSearchingOffline = false
    
    init(moviesService: MoviesProvidable, router: Coordinator) {
        self.moviesService = moviesService
        self.router = router
    }

    // MARK: - Public API
    
    func fetchInitialData() {
        view?.updateState(state: .initialDataLoadingStart)
        initialLoading = true
        fetchData()
    }
    
    func fetchMoreData() {
        isFetchingMoreData = true
        view?.updateState(state: .moreDataLoadingStart)
        
        if isSearchingMode {
            initialSearching = false
            searchData()
        } else {
            initialLoading = false
            fetchData()
        }
    }
    
    func searchMovie(title: String) {
        view?.updateState(state: .initialDataLoadingStart)
        initialSearching = true
        searchQuery = title
        searchTotalPages = 0
        filteredMovies = []
        searchData()
    }
    
    func didSelectMovieAt(_ indexPath: IndexPath) {
        let movie = filteredMovies[indexPath.row]
        goToMovieDetailsScreen?(movie.id)
    }
    
    func searchBarCancelButtonClicked() {
        filteredMovies = initialMovies
        isSearchingMode = false
        searchQuery = ""
        searchTotalPages = 0
        view?.updateState(state: .reloadData)
    }
    
    func willPresentSearch() {
        isSearchingMode = true
    }
    
    // MARK: - Private functions
    
    private func fetchData() {
        let page = getPage() + 1
        moviesService.fetchMovies(page: page, sortBy: currentSortOption) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.performFetchResult(result: result, page: page)
            }
        }
    }
    
    private func performFetchResult(result: Result<[MovieModel], CustomError>, page: Int) {
        switch result {
        case .success(let moviesArray):
            initialTotalPages = page
            initialDataLoadSuccess(moviesArray)
        case .failure(let error):
            if initialLoading {
                view?.updateState(state: .initialDataLoadingFailed(error))
            } else {
                isFetchingMoreData = false
                view?.updateState(state: .moreDataLoadingFailed(error))
            }
        }
    }
    
    private func searchData() {
        let page = getSearchPage() + 1
        moviesService.searchMovieByTitle(searchQuery, page: page) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.performSearchResult(result: result, page: page)
            }
        }
    }
    
    private func performSearchResult(result: Result<[MovieModel], CustomError>, page: Int) {
        switch result {
        case .success(let moviesArray):
            searchTotalPages = page
            filteredMovies.append(contentsOf: moviesArray)
            if initialSearching {
                view?.updateState(state: .initialDataLoadingFinished)
            } else {
                view?.updateState(state: .moreDataLoadingFinished)
            }
        case .failure(let error):
            handleSearchingError(error)
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
                view?.updateState(state: .initialDataLoadingFailed(error))
            } else {
                isFetchingMoreData = false
                view?.updateState(state: .moreDataLoadingFailed(error))
            }
        case .noInternetConnection:
            print("DEBUG: noInternetConnection")
            if initialSearching {
                filterMovie(title: self.searchQuery)
                isSearchingOffline = true
                view?.updateState(state: .offlineSearch(error))
            } else {
                isFetchingMoreData = false
                view?.updateState(state: .moreDataLoadingFailed(error))
            }
        }
    }
    
    private func initialDataLoadSuccess(_ movies: [MovieModel]) {
        if initialLoading {
            initialMovies.elements = movies
            filteredMovies.elements = movies
            view?.updateState(state: .initialDataLoadingFinished)
        } else {
            initialMovies.append(contentsOf: movies)
            filteredMovies.append(contentsOf: movies)
            view?.updateState(state: .moreDataLoadingFinished)
        }
    }
}
