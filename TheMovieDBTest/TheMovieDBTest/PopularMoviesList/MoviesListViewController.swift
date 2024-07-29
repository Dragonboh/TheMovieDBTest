//
//  ViewController.swift
//  TheMovieDBTest
//
//  Created by admin on 28.07.2024.
//

import UIKit
import UIScrollView_InfiniteScroll

class MoviesListViewController: UIViewController {
    
    @IBOutlet weak var titleAndYear: UILabel!
    @IBOutlet weak var genres: UILabel!
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var tableview: UITableView!
    
    private let moviesListVM = MoviesListViewModel()
    
    private var movies: [MovieModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchData()
    }
    private var pagesDownloaded = 1
    
    private func fetchData() {
        moviesListVM.fetchMoviesList(page: pagesDownloaded) { [weak self] moviesList, errorMessage in
            if let _ = errorMessage {
                return
            }
            
            guard let moviesList = moviesList else { return }
            DispatchQueue.main.async {
                self?.movies = moviesList
                self?.tableview.reloadData()
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
            return partialResult.appending(", \(genre)")
        })
        cell.ratingLabel.text = "\(movie.rating)"
        
        return cell
        
    }
}

extension MoviesListViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        let contentHeight = Double(movies.count * 240)
        let onScreen = scrollView.frame.size.height
        
        if (contentHeight - offset - onScreen) < 2400  && (!tableview.isAnimatingInfiniteScroll) {
            print("DEBUG: Fetch more dara")
            tableview.beginInfiniteScroll(false)
            
            moviesListVM.fetchMoviesList(page: pagesDownloaded + 1) { [weak self] moviesList, errorMessage in
                guard let self = self else { return }
                
                if let errorMessage = errorMessage {
                    print(errorMessage)
                    DispatchQueue.main.async {
                        self.tableview.finishInfiniteScroll()
                    }
                    
                    return
                }
                
                guard let moviesList = moviesList else { return }
                pagesDownloaded += 1
                DispatchQueue.main.async {
                    let startIndex = self.movies.count
                    let endIndex = self.movies.count + moviesList.count
                    let indices = Array(startIndex..<endIndex).compactMap {
                        IndexPath(row: $0, section: 0)
                    }
                    self.movies.append(contentsOf: moviesList)
                    self.tableview.insertRows(at: indices, with: .automatic)
                    self.tableview.finishInfiniteScroll()
                }
            }
        }
    }
}

