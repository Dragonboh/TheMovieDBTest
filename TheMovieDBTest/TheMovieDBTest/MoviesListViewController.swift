//
//  ViewController.swift
//  TheMovieDBTest
//
//  Created by admin on 28.07.2024.
//

import UIKit

class MoviesListViewController: UIViewController {
    
    @IBOutlet weak var titleAndYear: UILabel!
    @IBOutlet weak var genres: UILabel!
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var tableview: UITableView!
    
    private let moviesListVM = MoviesListViewModel()
    
    private var movies: [MovieModel] = [] {
        didSet {
            tableview.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        moviesListVM.fetchMoviesList { [weak self] moviesList in
            DispatchQueue.main.async {
                self?.movies = moviesList
            }
        }
    }
}

extension MoviesListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MoviewCell", for: indexPath) as! MoviewCell
        
        let movie = movies[indexPath.row]
        
        cell.imageName = movie.backdropPath
        cell.titleAndYearLabel.text = "\(movie.title), \(movie.releaseDate)"
        cell.genresLabel.text = movie.genres.reduce("", { partialResult, genre in
            return partialResult.appending(", \(genre.rawValue)")
        })
        cell.ratingLabel.text = "\(movie.rating)"
        
        return cell
        
    }
}

