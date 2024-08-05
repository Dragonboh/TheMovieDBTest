//
//  PopMoviesViewController.swift
//  TheMovieDBTest
//
//  Created by admin on 04.08.2024.
//

import UIKit
import JGProgressHUD
import SwiftUI

enum MovieListState {
    case initialDataLoadingStart
    case initialDataLoadingFinished
    case initialDataLoadingFailed(CustomError)
    
    case moreDataLoadingStart
    case moreDataLoadingFinished
    case moreDataLoadingFailed(CustomError)
    
    
    case reloadData
    case error(CustomError)
}



protocol MovieListScreenProtocol: AnyObject {
    func updateState(state: MovieListState)
}

class PopMoviesViewController: UIViewController, MovieListScreenProtocol {
    
    @IBOutlet weak var tableView: UITableView!
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var diffableDataSource: UITableViewDiffableDataSource<Int, MovieModel>!
    private var tableFooterLoadingView: TableFooterLoadingView?
    private var tableFooterErrorView: TableFooterErrorView?

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
    
    // OR we need PopMoviesListViewModelProtocol
    var moviesListVM: PopMoviesListViewModel
    
    private var lastScrollOffset = 0.0
    private var lastShowedCellIndex = 0
    
    private var isPullToRefreshRunning = false
    private var tableViewDragToEnd = false
    private var isFetchingMoreData = false
    private var isSearching = false
    private var isSearchingMode = false
    
    // Same here we could use PopMoviesListViewModelProtocol
    init?(coder: NSCoder, viewModel: PopMoviesListViewModel) {
        self.moviesListVM = viewModel
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("use init?(coder: NSCoder, viewModel: MoviesListViewModel) instead")
    }
    
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
            guard let cell = tableView.dequeueReusableCell(withIdentifier: PopMovieCell.identifier, for: indexPath) as? PopMovieCell else {
                assertionFailure("MoviewCell is bad configured in Storyboard with \(PopMovieCell.identifier) identifier")
                return UITableViewCell()
            }
            
            let genres = movie.genres?.map({ genre in
                genre.name
            })
            
            cell.configure(title: movie.title, releaseDate: movie.releaseDate, rating: movie.rating, genres: genres, imagePath: movie.posterPath)
            return cell
           
        })
    }
    
    private func setUpSearchController() {
//        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.searchBar.delegate = self
    }
    
    private func setUpTableView() {
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.refreshControl = tableRefreshControl
        tableView.backgroundView = .contentEmptyView

        let footerErrorView = TableFooterErrorView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 60))
        tableFooterErrorView = footerErrorView
        
        let footerLoadingView = TableFooterLoadingView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 60))
        tableFooterLoadingView = footerLoadingView
        
        footerErrorView.retryButton.addTarget(self, action: #selector(retryButtonTapped), for:  .touchUpInside)
        tableView.tableFooterView = tableFooterLoadingView
    }
    
    private func setUpNavigationBar() {
        title = "Popular Movies"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
//        navigationItem.searchController = searchController
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
            initialDataLoadingFinished()
            
        case .initialDataLoadingFailed(let error):
            
            if isPullToRefreshRunning {
                finishPullToRefreshAnimationIfNeeded()
                isPullToRefreshRunning = false
                tableView.configure(backgroundView: self.diffableDataSource.numberOfItems == 0 ? .failedToLoad : .none)
            }
            
            showAlertError(message: error.errorMessage)
            
        case .moreDataLoadingStart:
            print("DEBUG: More data loading start")

        case .moreDataLoadingFinished:
            updateDiffableDataSource()
            
            if tableViewDragToEnd {
                tableView.tableFooterView = tableFooterLoadingView
                tableViewDragToEnd = false
            }
            
        case .moreDataLoadingFailed(let error):
            isFetchingMoreData = false
            if (lastShowedCellIndex == (diffableDataSource.numberOfItems - 1)) && !tableViewDragToEnd {
                showAlertError(message: error.errorMessage)
                tableView.tableFooterView = tableFooterErrorView
                tableViewDragToEnd = true
            } else if tableViewDragToEnd {
                showAlertError(message: error.errorMessage)
            }

        case .error(let error):
            handleError(errorMessage: error.errorMessage)
           
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
        print("DEBUG: pullToRefresh")
        isPullToRefreshRunning = true
        
        if isSearchingMode {
            moviesListVM.searchMovie(title: searchController.searchBar.text ?? "")
        } else {
            fetchInitialData()
        }
    }
    
    private func initialDataLoadingFinished() {
        
        if isPullToRefreshRunning {
            finishPullToRefreshAnimationIfNeeded()
        } else {
            progressHUD.dismiss()
        }
        
        updateDiffableDataSource(initialLoad: true)
    }
    
    private func handleError(errorMessage: String) {
//        if isPullToRefreshRunning {
//            finishPullToRefreshAnimationIfNeeded()
//        }
//        
//        if tableViewDragToEnd {
//            stopInfinitiveScroll()
//            showAlertError(message: errorMessage)
//            isFetchingMoreData = false
//            return
//        }
//        
//        if isFetchingMoreData {
//            isFetchingMoreData = false
//            return
//        }
//        
//        updateDiffableDataSource()
//        showAlertError(message: errorMessage)
//        progressHUD.dismiss()
//        tableView.isHidden = false
//        tableView.configure(backgroundView: diffableDataSource.numberOfItems == 0 ? .failedToLoad : .none)
//        tableView.isHidden = false
    }
    
    private func finishPullToRefreshAnimationIfNeeded() {
        tableView.setContentOffset(CGPoint.zero, animated: true)
        tableRefreshControl.endRefreshing()
    }

    private func sortMovies(by sortOption: SortOption) {
        print("DEBUG: new sort option: \(sortOption.title)")
        moviesListVM.currentSortOption = sortOption
        fetchInitialData()
    }
    
    private func showAlertError(message: String, complition: (() -> Void)? = nil) {
        let alertVC = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alertVC, animated: true, completion: nil)
    }
    
    @objc
    private func retryButtonTapped() {
        isFetchingMoreData = true
        moviesListVM.fetchMoreData()
    }
}

// MARK: - UITableViewDelegate

extension PopMoviesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        moviesListVM.didSelectRowAt(indexPath)
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        print("Will DIsplay: ", indexPath.row)
        if (indexPath.row > (diffableDataSource.numberOfItems - 10)) && !isFetchingMoreData && !tableViewDragToEnd {
            isFetchingMoreData = true
            moviesListVM.fetchMoreData()
        }
        
        if indexPath.row > lastShowedCellIndex {
            lastShowedCellIndex = indexPath.row
        }
    }
}

// MARK: - UISearchBarDelegate, UISearchControllerDelegate

extension PopMoviesViewController: UISearchControllerDelegate, UISearchBarDelegate {
    
    func willPresentSearchController(_ searchController: UISearchController) {
        tableView.isHidden = true
//        isSearching = true
        isSearchingMode = true
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchController.searchBar.text else { return }
        print("DEBUG: searchBarSearchButtonClicked with text: \(text)")
        moviesListVM.searchMovie(title: text)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("DEBUG: searchBarCancelButtonClicked")
        isSearchingMode = false
        moviesListVM.searchBarCancelButtonClicked()
    }
}

//MARK: - @IBActions

extension PopMoviesViewController {
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

