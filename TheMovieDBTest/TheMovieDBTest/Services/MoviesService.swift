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

final class ImageService {

    func loadImage(path: String) {
        let url = URL(string: "https://image.tmdb.org/t/p/w780/\(path)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let imageTask = URLSession.shared.dataTask(with: request) { [weak self] data, responce, error in
            if let error = error {
                print("DEBUG: error in getting popular movies, error: \(error.localizedDescription)")
                return
            }
            
            guard let _ = responce as? HTTPURLResponse else {
                print("DEBUG: bad response")
                return
            }
            
            guard let data = data else {
                print("DEBUG: no data")
                return
            }
            
//            guard let image = UIImage(data: data) else {
//                print("DEBUG: cannot decode image")
//                return
//            }
            
//            if urlImageName == self?.imageName {
//                DispatchQueue.main.async { [weak self] in
//                    self?.movieImageView.image = image
//                }
//            }
        }
        
//        downloadImageTasks[imageName] = imageTask
        imageTask.resume()
    }
}

//protocol ImageLoader: AnyObject {
//    func displayImageAtPath(_ path: String)
//    
//    var displayImageView: UIImageView { get set }
//}
//
//import UIKit
//
//extension ImageLoader {
//    func displayImageAtPath(path: String) {
//        let url = URL(string: "https://image.tmdb.org/t/p/w780/\(path)")!
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        
//        let imageTask = URLSession.shared.dataTask(with: request) { [weak self] data, responce, error in
//            if let error = error {
//                print("DEBUG: error in getting popular movies, error: \(error.localizedDescription)")
//                return
//            }
//            
//            guard let _ = responce as? HTTPURLResponse else {
//                print("DEBUG: bad response")
//                return
//            }
//            
//            guard let data = data else {
//                print("DEBUG: no data")
//                return
//            }
//            
//            guard let image = UIImage(data: data) else {
//                print("DEBUG: cannot decode image")
//                return
//            }
//            
//            if urlImageName == self?.imageName {
//                DispatchQueue.main.async { [weak self] in
//                    displayImageView.image = image
//                    
//                }
//            }
//        }
//        
////        downloadImageTasks[imageName] = imageTask
//        imageTask.resume()
//    }
//}
