//
//  MoviesListViewModel.swift
//  TheMovieDBTest
//
//  Created by admin on 28.07.2024.
//

import Foundation

enum ScreenState {
    case one
    case two
}

enum CustomError: Error {
    case error(String)
    
    var errorMessage: String {
        switch self {
        case .error(let message):
            return message
        }
    }
}

protocol ScreenProtocol: AnyObject {
    func updateState(state: ScreenState)
}

class MoviesListViewModel {
    
    private let moviesService: MoviesService
    private let router: Router
    
    private var totalPagesDownloaded = 0
    
    weak var screen: MovieListScreenProtocol?

    var currentSortOption: SortOption = .popularity
    var movies: [MovieModel] = []
    
    init(moviesService: MoviesService, router: Router) {
        self.moviesService = moviesService
        self.router = router
    }

    func fetchInitialData2() {
        movies = []
        screen?.updateState(state: .initialDataLoadingStart)
        fetchData2(page: 1) { [weak self] result in
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
    
    func fetchMoreData2() {
        screen?.updateState(state: .moreDataLoadingStart)
        fetchData2(page: totalPagesDownloaded + 1) { [weak self] result in
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
    
//    func fetchInitialData(complition: @escaping (String?) -> Void) {
//        movies = []
//        fetchData(page: 1) { [weak self] moviesArray, errorMessage in
//            guard let self = self else { return }
//            if let errorMessage = errorMessage {
//                complition(errorMessage)
//            }
//            guard let moviesArray = moviesArray else { return }
//            movies.append(contentsOf: moviesArray)
//            complition(nil)
//        }
//    }
    
//    func fetchMoreData(complition: @escaping ([IndexPath]?, String?) -> Void) {
//        fetchData(page: totalPagesDownloaded + 1) {[weak self] moviesArray, errorMessage in
//            guard let self = self else { return }
//            if let errorMessage = errorMessage {
//                complition(nil, errorMessage)
//            }
//            guard let moviesArray = moviesArray else { return }
//            let startIndex = movies.count
//            let endIndex = movies.count + moviesArray.count
//            let indices = Array(startIndex..<endIndex).compactMap {
//                IndexPath(row: $0, section: 0)
//            }
//            movies.append(contentsOf: moviesArray)
//            complition(indices, nil)
//        }
//    }
    
//    private func fetchData(page: Int, complition: @escaping ([MovieModel]?, String?) -> Void) {
//        moviesService.fetchPopularMovies(page: page, sortBy: currentSortOption) { [weak self] data, errorMessage in
//            guard let self = self else { return }
//            
//            if let errorMessage = errorMessage {
//                print("DEBUG: error in fetching data for popular movies list: \(errorMessage)")
//                complition(nil, errorMessage)
//                return
//            }
//            
//            guard let moviesArray = data else { return }
//            totalPagesDownloaded = page
//            complition(moviesArray, nil)
//        }
//    }
    
    private func fetchData2(page: Int, complition: @escaping (Result<[MovieModel], CustomError>) -> Void) {
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
