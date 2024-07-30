//
//  MoviesService.swift
//  TheMovieDBTest
//
//  Created by admin on 28.07.2024.
//

import Foundation


final class MoviesService {
    
    func fetchPopularMovies(page: Int, complition: @escaping ([MovieModel]?, String?) -> Void) {
        let url = URL(string: "https://api.themoviedb.org/3/movie/popular")!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "language", value: "en-US"),
            URLQueryItem(name: "page", value: "\(page)"),
        ]
        components.queryItems = components.queryItems.map { $0 + queryItems } ?? queryItems
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.allHTTPHeaderFields = [
            "accept": "application/json",
            "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI4MzU2NDVhMzAyN2VhYzFhOTc3YmRlZTc0ZmQ4MWEzZCIsIm5iZiI6MTcyMjAxMTE3Mi41MTEzODEsInN1YiI6IjY2YTNjYmNhODQ1NjM4YmYxOTcwOGMzOCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.Ma0Y2QR4Sbv9WLcZ7uDCsq0_RwL-0ifo82gI5fZAVEw"
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
                DispatchQueue.main.async {
                    complition(results.results, nil)
                }
            } catch {
                print("DEBUG: cannot decode JSON")
                
                print(error.localizedDescription)
                complition(nil, "DEBUG: cannot decode JSON")
            }
//            guard let results = try? JSONDecoder().decode(Response<MovieModel>.self, from: data) else {
//                let jsonObject = try? JSONSerialization.jsonObject(with: data)
//                print(jsonObject)
//                print("DEBUG: cannot decode JSON")
//                return
//            }
//            
//            DispatchQueue.main.async {
//                complition(results.results)
//            }
        }.resume()
    }
}