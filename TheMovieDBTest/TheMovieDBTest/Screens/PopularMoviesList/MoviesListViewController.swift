//
//  ViewController.swift
//  TheMovieDBTest
//
//  Created by admin on 28.07.2024.
//

import UIKit
import UIScrollView_InfiniteScroll
import JGProgressHUD

enum MovieListState {
    case initialDataLoadingStart
    case initialDataLoadingFinished
    case moreDataLoadingStart
    case moreDataLoadedFinished([IndexPath])
    case reloadData
    case error(String)
}

protocol MovieListScreenProtocol: AnyObject {
    func updateState(state: MovieListState)
}

class MoviesListViewController: UIViewController, MovieListScreenProtocol {

    @IBOutlet weak var tableView: UITableView!
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    lazy var progressHUD: JGProgressHUD = {
        let hud = JGProgressHUD()
        hud.textLabel.text = "Loading"
        hud.detailTextLabel.text = "Please wait"
        return hud
    }()
    
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
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.searchBar.delegate = self
        
        tableView.estimatedRowHeight = 240
        tableView.rowHeight = UITableView.automaticDimension
        tableView.refreshControl = tableRefreshControl
        
        fetchInitialData()
    }
    
    private func setUpNavigationBar() {
        title = "Popular Movies"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.searchController = searchController
    }
    
    func updateState(state: MovieListState) {
        switch state {
        case .initialDataLoadingStart:
            if !isPullToRefreshRunning {
                progressHUD.show(in: view)
            }
            
        case .initialDataLoadingFinished:
            if isPullToRefreshRunning {
                finishPullToRefreshAnimation()
            } else {
                progressHUD.dismiss()
            }
            tableView.isHidden = false
            tableView.reloadData()
            
        case .moreDataLoadingStart:
            tableView.beginInfiniteScroll(false)
            
        case .moreDataLoadedFinished(let indices):
            tableView.insertRows(at: indices, with: .automatic)
            tableView.finishInfiniteScroll()
            
        case .error(let errorMessage):
            if isPullToRefreshRunning {
                finishPullToRefreshAnimation()
                showAlertError(message: errorMessage)
                break
            }
            
            if tableViewDragToEnd {
                showAlertError(message: errorMessage)
                tableView.finishInfiniteScroll()
                break
            }
            
            progressHUD.dismiss()
            tableView.configure(backgroundView: .failedToLoad)
            showAlertError(message: errorMessage)
            
        case .reloadData:
            tableView.reloadData()
            tableView.isHidden = false
        }
    }
    
    private func finishPullToRefreshAnimation() {
//        let delay = DispatchTime.now() + .microseconds(500)
//        DispatchQueue.main.asyncAfter(deadline: delay) { [weak self] in
//            self?.tableRefreshControl.endRefreshing()
//        }
        tableRefreshControl.endRefreshing()
        isPullToRefreshRunning = false
    }
    
    private func fetchInitialData() {
        print("DEBUG: Fetch initial data")
        moviesListVM.fetchInitialData()
    }
    
    private func fetchMoreData(endDragging: Bool) {
        print("DEBUG: Fetch more data")
        tableViewDragToEnd = endDragging
        moviesListVM.fetchMoreData()
        tableView.beginInfiniteScroll(false)
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
        moviesListVM.filteredMovies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MoviewCell", for: indexPath) as! MoviewCell
        
        let movie = moviesListVM.filteredMovies[indexPath.row]
        
        let genres = movie.genres?.map({ genre in
            genre.name
        })
        
        cell.configure(title: movie.title, year: movie.releaseDate, rating: movie.rating, genres: genres, imagePath: movie.backdropPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        moviesListVM.didSelectRowAt(indexPath)
    }
}

extension MoviesListViewController: UIScrollViewDelegate {
    private func offset(_ scrollView: UIScrollView) -> Double {
        let offset = scrollView.contentOffset.y
        let contentHeight = Double(moviesListVM.filteredMovies.count * 240)
        let onScreen = scrollView.frame.size.height
        let counter = contentHeight - offset - onScreen
        
        return counter
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let counter = offset(scrollView)
        if (counter < lastScrollOffset) && (counter < 2400) && (counter > -11) && (!tableView.isAnimatingInfiniteScroll) {
            fetchMoreData(endDragging: false)
        }
        lastScrollOffset = counter
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let counter = offset(scrollView)
        if counter < -11.0 && !moviesListVM.filteredMovies.isEmpty {
            fetchMoreData(endDragging: true)
        }
    }
}

extension MoviesListViewController: UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
//        guard let text = searchController.searchBar.text else {
//            return
//        }
////        print("updateSearchResults:  -\(text)-")
////        tableview.isHidden = true
//        moviesListVM.filterMovie(name: text)
////        moviesListVM.updateSearchResults()
//        tableview.reloadData()
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        print("willDismissSearchController")
    }
    
    func willPresentSearchController(_ searchController: UISearchController) {
        tableView.isHidden = true
    }
    
//    func didPresentSearchController(_ searchController: UISearchController) {
//        tableview.isHidden = true
//    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("searchBarSearchButtonClicked")
        guard let text = searchController.searchBar.text else { return }
        moviesListVM.searchMovie(title: text)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("searchBarCancelButtonClicked")
        moviesListVM.searchBarCancelButtonClicked()
    }
}

