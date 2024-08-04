//
//  ViewController.swift
//  TheMovieDBTest
//
//  Created by admin on 28.07.2024.
//

import UIKit
import JGProgressHUD

enum MovieListState {
    case initialDataLoadingStart
    case initialDataLoadingFinished
    case moreDataLoadingStart
    case moreDataLoadedFinished
    case reloadData
    case error(String)
}

protocol MovieListScreenProtocol: AnyObject {
    func updateState(state: MovieListState)
}

class MoviesListViewController: UIViewController, MovieListScreenProtocol {

    @IBOutlet weak var tableView: UITableView!
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var diffableDataSource: UITableViewDiffableDataSource<Int, MovieModel>!

    private lazy var progressHUD: JGProgressHUD = {
        let hud = JGProgressHUD()
        hud.textLabel.text = "Loading"
        hud.detailTextLabel.text = "Please wait"
        return hud
    }()
    
    private lazy var tableRefreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        
        return refreshControl
    }()
    
    var moviesListVM: MoviesListViewModel!
    
    private var lastScrollOffset = 0.0
    private var isPullToRefreshRunning = false
    private var tableViewDragToEnd = false
    private var isFetchingMoreData = false
    private var isSearching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpNavigationBar()
        setUpTableViewDiffableDataSource()
        setUpSearchController()
        setUpTableView()

        fetchInitialData()
    }
    
    
    // MARK: - initial setUp functions
    
    private func setUpTableViewDiffableDataSource() {
        diffableDataSource = UITableViewDiffableDataSource<Int, MovieModel>(tableView: tableView, cellProvider: { tableView, indexPath, movie in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: MoviewCell.identifier, for: indexPath) as? MoviewCell else {
                assertionFailure("MoviewCell is bad configured in Storyboard with \(MoviewCell.identifier) identifier")
                return UITableViewCell()
            }
            
            let genres = movie.genres?.map({ genre in
                genre.name
            })
            
            cell.configure(title: movie.title, year: movie.releaseDate, rating: movie.rating, genres: genres, imagePath: movie.backdropPath)
            return cell
        })
    }
    
    private func setUpSearchController() {
//        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.searchBar.delegate = self
    }
    
    private func setUpTableView() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.refreshControl = tableRefreshControl
        tableView.backgroundView = .contentEmptyView
    }
    
    private func setUpNavigationBar() {
        title = "Popular Movies"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    // MARK: - Update State
    
    func updateState(state: MovieListState) {
        switch state {
        case .initialDataLoadingStart:
            if !isPullToRefreshRunning {
                progressHUD.show(in: view)
            }
            
        case .initialDataLoadingFinished:
            if isPullToRefreshRunning {
                finishPullToRefreshAnimationIfNeeded()
            } else {
                progressHUD.dismiss()
            }
            
            if isSearching {
                tableView.isHidden = false
            }
            
            updateDiffableDataSource(initialLoad: true)
            
        case .moreDataLoadingStart:
            startInfinitiveScroll()
            
        case .moreDataLoadedFinished:
            updateDiffableDataSource()
            stopInfinitiveScroll()
    
        case .error(let errorMessage):
            

            if isPullToRefreshRunning {
                finishPullToRefreshAnimationIfNeeded()
            }
            
            if tableViewDragToEnd {
                stopInfinitiveScroll()
            }
            
            if isFetchingMoreData {
                isFetchingMoreData = false
                break
            }
            
            showAlertError(message: errorMessage)
            progressHUD.dismiss()
            tableView.configure(backgroundView: diffableDataSource.numberOfItems == 0 ? .failedToLoad : .none)
            
            
        case .reloadData:
            updateDiffableDataSource()
        }
    }
    
    // MARK: - Main Flow
    
    private func updateDiffableDataSource(initialLoad: Bool = false) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, MovieModel>()
        snapshot.appendSections([0])
        snapshot.appendItems(moviesListVM.filteredMovies)
        
        diffableDataSource.apply(snapshot, animatingDifferences: !initialLoad) { [weak self] in
            guard let self = self else { return }
            if !initialLoad {
                isFetchingMoreData = false
            }
            
            tableView.configure(backgroundView: diffableDataSource.numberOfItems == 0 ? .empty : .none)
        }
    }
    
    private func fetchInitialData() {
        print("DEBUG: Fetch initial data")
        moviesListVM.fetchInitialData()
    }
    
    @objc
    private func pullToRefresh() {
        if isSearching {
            return
        }
        print("DEBUG: pullToRefresh")
        isPullToRefreshRunning = true
        fetchInitialData()
    }
    
    private func finishPullToRefreshAnimationIfNeeded() {
//        let delay = DispatchTime.now() + .microseconds(500)
//        DispatchQueue.main.asyncAfter(deadline: delay) { [weak self] in
//            self?.tableRefreshControl.endRefreshing()
//        }
        tableRefreshControl.endRefreshing()
        isPullToRefreshRunning = false
    }
    
    private func startInfinitiveScroll() {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 100))
        
        let spinner = UIActivityIndicatorView()
        spinner.style = .large
        spinner.color = .purple
        spinner.center = footerView.center
        footerView.addSubview(spinner)
        
        spinner.startAnimating()
        tableView.tableFooterView = footerView
    }
    
    private func stopInfinitiveScroll() {
        tableView.tableFooterView = nil
    }
    
    private func fetchMoreData(endDragging: Bool) {
        print("DEBUG: Fetch more data")
        tableViewDragToEnd = endDragging
        moviesListVM.fetchMoreData()
    }
    
    private func sortMovies(by sortOption: SortOption) {
        print("DEBUG: new sort option: \(sortOption.title)")
        moviesListVM.currentSortOption = sortOption
        fetchInitialData()
    }
    
    private func showAlertError(message: String) {
        let alertVC = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alertVC, animated: true)
    }
}

// MARK: - UITableViewDelegate

extension MoviesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        moviesListVM.didSelectRowAt(indexPath)
        tableView.deselectRow(at: indexPath, animated: false)
    }
}

// MARK: - UIScrollViewDelegate

extension MoviesListViewController: UIScrollViewDelegate {
    private func offset(_ scrollView: UIScrollView) -> Double {
        let offset = scrollView.contentOffset.y
        let contentHeight = Double(diffableDataSource.numberOfItems * 240)
        let onScreen = scrollView.frame.size.height
        let counter = contentHeight - offset - onScreen
        
        return counter
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isFetchingMoreData {
            return
        }
        
        let offset = offset(scrollView)
        print(offset)
        if (offset < lastScrollOffset) && (offset < 2400) && (offset > -11) {
            isFetchingMoreData = true
            fetchMoreData(endDragging: false)
        }
        lastScrollOffset = offset
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if isFetchingMoreData {
            return
        }

        let offset = offset(scrollView)
        if offset < -11.0 && diffableDataSource.isEmpty {
            isFetchingMoreData = true
            fetchMoreData(endDragging: true)
        }
    }
}

// MARK: - UISearchBarDelegate, UISearchControllerDelegate

extension MoviesListViewController: UISearchControllerDelegate, UISearchBarDelegate {
    
    func willPresentSearchController(_ searchController: UISearchController) {
        tableView.isHidden = true
        isSearching = true
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchController.searchBar.text else { return }
        print("DEBUG: searchBarSearchButtonClicked with text: \(text)")
        moviesListVM.searchMovie(title: text)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("searchBarCancelButtonClicked")
        isSearching = false
        tableView.isHidden = false
        moviesListVM.searchBarCancelButtonClicked()
    }
}

//MARK: - @IBActions

extension MoviesListViewController {
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
