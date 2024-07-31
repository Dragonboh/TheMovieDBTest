//
//  ViewController.swift
//  TheMovieDBTest
//
//  Created by admin on 28.07.2024.
//

import UIKit
import UIScrollView_InfiniteScroll

enum MovieListState {
    case initialDataLoadingStart
    case initialDataLoadingFinished
    case moreDataLoadingStart
    case moreDataLoadedFinished([IndexPath])
    case error(String)
}

protocol MovieListScreenProtocol: AnyObject {
    func updateState(state: MovieListState)
}

class MoviesListViewController: UIViewController, MovieListScreenProtocol {

    @IBOutlet weak var tableview: UITableView!
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    lazy var tableRefreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        
        return refreshControl
    }()
    
    var moviesListVM: MoviesListViewModel!
    
    private var lastScrollOffset = 0.0
    private var isPullToRefreshRunning = false
    private var tableViewDragToEnd = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpNavigationBar()
        
        tableview.estimatedRowHeight = 240
        tableview.rowHeight = UITableView.automaticDimension
        tableview.refreshControl = tableRefreshControl
        tableview.isHidden = true
        
        activityIndicatorView.hidesWhenStopped = true
        
        fetchInitialData()
    }
    
    private func setUpNavigationBar() {
        self.navigationItem.title = "Popular Movies"
    }
    
    func updateState(state: MovieListState) {
        switch state {
        case .initialDataLoadingStart:
            if !isPullToRefreshRunning {
                activityIndicatorView.isHidden = false
                activityIndicatorView.startAnimating()
            }
        case .initialDataLoadingFinished:
            tableview.isHidden = false
            tableview.reloadData()
            if isPullToRefreshRunning {
                finishPullToRefreshAnimation()
            } else {
                activityIndicatorView.stopAnimating()
            }
        case .moreDataLoadingStart:
            tableview.beginInfiniteScroll(false)
        case .moreDataLoadedFinished(let indices):
            tableview.insertRows(at: indices, with: .automatic)
            tableview.finishInfiniteScroll()
        case .error(let errorMessage):
            if isPullToRefreshRunning {
                finishPullToRefreshAnimation()
                showAlertError(message: errorMessage)
                break
            }
            
            if tableViewDragToEnd {
                showAlertError(message: errorMessage)
                tableview.finishInfiniteScroll()
                break
            }
            
            if activityIndicatorView.isAnimating {
                activityIndicatorView.stopAnimating()
            }
            
            showAlertError(message: errorMessage)
        }
    }
    
    private func finishPullToRefreshAnimation() {
        let delay = DispatchTime.now() + .microseconds(500)
        DispatchQueue.main.asyncAfter(deadline: delay) { [weak self] in
            self?.tableRefreshControl.endRefreshing()
        }
        isPullToRefreshRunning = false
    }
    
    private func fetchInitialData() {
        print("DEBUG: Fetch initial data")
        moviesListVM.fetchInitialData2()
        
//        moviesListVM.fetchInitialData { [weak self] errorMessage in
//            DispatchQueue.main.async {
//                if let errorMessage = errorMessage {
//                    print(errorMessage)
//                    self?.showAlertError(message: errorMessage)
//                } else {
//                    self?.tableview.reloadData()
//                }
//                
//                let delay = DispatchTime.now() + .microseconds(500)
//                DispatchQueue.main.asyncAfter(deadline: delay) {
//                    self?.tableRefreshControl.endRefreshing()
//                }
//            }
//        }
    }
    
    private func fetchMoreData(endDragging: Bool) {
        print("DEBUG: Fetch more data")
        tableViewDragToEnd = endDragging
        moviesListVM.fetchMoreData2()
        
        
        tableview.beginInfiniteScroll(false)
        
//        moviesListVM.fetchMoreData { [weak self] indices, errorMessage in
//            if let errorMessage = errorMessage {
//                DispatchQueue.main.async {
//                    if endDragging {
//                        self?.showAlertError(message: errorMessage)
//                    }
//                    self?.tableview.finishInfiniteScroll()
//                }
//                
//                return
//            }
//            
//            guard let indices = indices else { return }
//            
//            DispatchQueue.main.async { [weak self] in
//                self?.tableview.insertRows(at: indices, with: .automatic)
//                self?.tableview.finishInfiniteScroll()
//            }
//        }
    }
    
    private func sortMovies(by sortOption: SortOption) {
        print("DEBUG: new sort option: \(sortOption.title)")
        moviesListVM.currentSortOption = sortOption
        fetchInitialData()
    }
    
    @objc
    private func pullToRefresh() {
        isPullToRefreshRunning = true
        fetchInitialData()
    }
    
    private func showAlertError(message: String) {
        let alertVC = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alertVC, animated: true)
    }
    
    @IBAction func showSortOptionsActionSheet(_ sender: Any) {
        let actionSheet = UIAlertController(title: "Select an Option", message: nil, preferredStyle: .actionSheet)
        
        // Add actions to the action sheet
        let popularityOption = UIAlertAction(title: SortOption.popularity.title, style: .default) { [weak self] _ in
            self?.sortMovies(by: .popularity)
        }
        
        let ratingOption = UIAlertAction(title: SortOption.rating.title, style: .default) { [weak self] _ in
            self?.sortMovies(by: .rating)
        }
        
        let titleOption = UIAlertAction(title: SortOption.title.title, style: .default) { [weak self] _ in
            self?.sortMovies(by: .title)
        }
        
        switch moviesListVM.currentSortOption {
        case .popularity:
            popularityOption.setValue(true, forKey: "checked")
        case .title:
            titleOption.setValue(true, forKey: "checked")
        case .rating:
            ratingOption.setValue(true, forKey: "checked")
        }
        
        let cancelAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        
        actionSheet.addAction(popularityOption)
        actionSheet.addAction(ratingOption)
        actionSheet.addAction(titleOption)
        actionSheet.addAction(cancelAction)
        
        // Present the action sheet
        present(actionSheet, animated: true, completion: nil)
    }
}

extension MoviesListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        moviesListVM.movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MoviewCell", for: indexPath) as! MoviewCell
        
        let movie = moviesListVM.movies[indexPath.row]
        
        
        cell.imageName = movie.backdropPath
         
//        moviesListVM.loadImage() { data in
//            guard let image = UIImage(data: data) else {
//                print("DEBUG: cannot decode image")
//                return
//            }
//            
//            if cell.imageName == movie.backdropPath {
//                DispatchQueue.main.async { [weak cell] in
//                    cell?.movieImageView.image = image
//                }
//            }
//        }
        
        cell.titleAndYearLabel.text = "\(movie.title), \(movie.releaseDate)"
        cell.genresLabel.text = movie.genres?.reduce("", { partialResult, genre in
            return partialResult.appending(", \(genre)")
        })
        cell.ratingLabel.text = "\(movie.rating)"
        
        return cell
        
    }
}

extension MoviesListViewController: UIScrollViewDelegate {
    private func offset(_ scrollView: UIScrollView) -> Double {
        let offset = scrollView.contentOffset.y
        let contentHeight = Double(moviesListVM.movies.count * 240)
        let onScreen = scrollView.frame.size.height
        let counter = contentHeight - offset - onScreen
        
        return counter
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let counter = offset(scrollView)
        if (counter < lastScrollOffset) && (counter < 2400) && (counter > -11) && (!tableview.isAnimatingInfiniteScroll) {
            fetchMoreData(endDragging: false)
        }
        lastScrollOffset = counter
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let counter = offset(scrollView)
        if counter < -11.0 {
            fetchMoreData(endDragging: true)
        }
    }
}

