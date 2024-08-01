//
//  MoviesService.swift
//  TheMovieDBTest
//
//  Created by admin on 28.07.2024.
//

import Foundation

protocol SortByQuery {
    var queryValue: String { get }
}

final class MoviesService {
    
    private let authorizationToken = "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI4MzU2NDVhMzAyN2VhYzFhOTc3YmRlZTc0ZmQ4MWEzZCIsIm5iZiI6MTcyMjAxMTE3Mi41MTEzODEsInN1YiI6IjY2YTNjYmNhODQ1NjM4YmYxOTcwOGMzOCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.Ma0Y2QR4Sbv9WLcZ7uDCsq0_RwL-0ifo82gI5fZAVEw"
    
    func fetchPopularMovies(page: Int, sortBy: SortByQuery? = nil, complition: @escaping ([MovieModel]?, String?) -> Void) {
        let url = URL(string: "https://api.themoviedb.org/3/discover/movie")!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        let queryItems: [URLQueryItem] = [
          URLQueryItem(name: "include_adult", value: "false"),
          URLQueryItem(name: "include_video", value: "false"),
          URLQueryItem(name: "language", value: "en-US"),
          URLQueryItem(name: "page", value: "\(page)"),
          URLQueryItem(name: "sort_by", value: sortBy?.queryValue ?? "popularity.desc"),
        ]
        components.queryItems = components.queryItems.map { $0 + queryItems } ?? queryItems

        var request = URLRequest(url: components.url!)
        request.timeoutInterval = 10
        request.allHTTPHeaderFields = [
          "accept": "application/json",
          "Authorization": authorizationToken
        ]
        
        URLSession.shared.dataTask(with: request) { data, responce, error in
            if let error = error {
                print("DEBUG: error in getting popular movies, error: \(error.localizedDescription)")
                complition(nil, "DEBUG: error in getting popular movies, error: \(error.localizedDescription)")
                return
            }
            
            guard let _ = responce as? HTTPURLResponse else {
                print("DEBUG: bad response")
                complition(nil, "DEBUG: bad response")
                return
            }
            
            guard let data = data else {
                print("DEBUG: no data")
                complition(nil, "DEBUG: no data")
                return
            }
            
            do {
                let results = try JSONDecoder().decode(Response<MovieModel>.self, from: data)
                complition(results.results, nil)
            } catch {
                print("DEBUG: cannot decode JSON")
                
                print(error.localizedDescription)
                complition(nil, "DEBUG: cannot decode JSON")
            }
        }.resume()
    }
    
    func fetchMovieDetailsAppendVideos(movieId: Int, complition: @escaping (Result<MovieDetails, CustomError>) -> Void) {
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(movieId)")!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        let queryItems: [URLQueryItem] = [
          URLQueryItem(name: "append_to_response", value: "videos"),
          URLQueryItem(name: "language", value: "en-US"),
        ]
        components.queryItems = components.queryItems.map { $0 + queryItems } ?? queryItems

        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.allHTTPHeaderFields = [
          "accept": "application/json",
          "Authorization": authorizationToken
        ]

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("DEBUG: error in getting popular movies, error: \(error.localizedDescription)")
                complition(.failure(.error(error.localizedDescription)))
                return
            }
            
            guard let _ = response as? HTTPURLResponse else {
                print("DEBUG: bad response")
                complition(.failure(.error("bad response")))
                return
            }
            
            guard let data = data else {
                print("DEBUG: no data")
                complition(.failure(.error("no response data")))
                return
            }
            
            do {
                let results = try JSONDecoder().decode(MovieDetails.self, from: data)
                
                complition(.success(results))
            } catch {
                print("DEBUG: cannot decode JSON, error: \(error.localizedDescription)")
                complition(.failure(.error(error.localizedDescription)))
            }
        }.resume()
    }
}

