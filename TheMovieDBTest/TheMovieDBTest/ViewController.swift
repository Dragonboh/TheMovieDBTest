//
//  ViewController.swift
//  TheMovieDBTest
//
//  Created by admin on 28.07.2024.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var titleAndYear: UILabel!
    @IBOutlet weak var genres: UILabel!
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var tableview: UITableView!
    
    private var movies: [MovieModel] = [] {
        didSet {
            tableview.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string: "https://api.themoviedb.org/3/movie/popular")!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        let queryItems: [URLQueryItem] = [
          URLQueryItem(name: "language", value: "en-US"),
          URLQueryItem(name: "page", value: "1"),
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
                return
            }
            
            guard let response = responce as? HTTPURLResponse else {
                print("DEBUG: bad response")
                return
            }
            
            guard let data = data else {
                print("DEBUG: no data")
                return
            }
            
            guard let results = try? JSONDecoder().decode(Response<MovieModel>.self, from: data) else {
                print("DEBUG: cannot decode JSON")
                return
            }
            
            DispatchQueue.main.async {
                self.movies = results.results
            }
            
            print(results.results)
        }.resume()
        
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MoviewCell", for: indexPath) as! MoviewCell
        
        let movie = movies[indexPath.row]
        
        cell.movieImageView?.image = UIImage(named: "badBoys")

        cell.titleAndYearLabel.text = movie.title
        cell.genresLabel.text = movie.releaseDate
        cell.ratingLabel.text = "\(movie.rating)"
        
        return cell
        
    }
}

