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
    
    case offlineSearch(CustomError)
    case reloadData
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
        hud.textLabel.text = "Loading".localized()
        hud.detailTextLabel.text = "Please wait".localized()
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
    private var isSearchingOffline = false
    
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
        searchController.delegate = self
        searchController.searchBar.delegate = self
    }
    
    private func setUpTableView() {
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.refreshControl = tableRefreshControl
        tableView.backgroundView = .none

        let footerErrorView = TableFooterErrorView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 60))
        tableFooterErrorView = footerErrorView
        
        let footerLoadingView = TableFooterLoadingView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 60))
        tableFooterLoadingView = footerLoadingView
        
        footerErrorView.retryButton.addTarget(self, action: #selector(retryButtonTapped), for:  .touchUpInside)
    }
    
    private func setUpNavigationBar() {
        navigationItem.title = "Popular Movies".localized()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    // MARK: - Update State
    
    func updateState(state: MovieListState) {
        switch state {
        case .initialDataLoadingStart:
            print("DEBUG: initialDataLoadingStart")
            if !isPullToRefreshRunning {
                progressHUD.show(in: view)
            }
            
        case .initialDataLoadingFinished:
            print("DEBUG: initialDataLoadingFinished")
            initialDataLoadingFinished()
            
        case .initialDataLoadingFailed(let error):
            initialDataLoadingFailed(error)
            
        case .moreDataLoadingStart:
            print("DEBUG: More data loading start")

        case .moreDataLoadingFinished:
            moreDataLoadingFinished()
            
        case .moreDataLoadingFailed(let error):
            moreDataLoadingFailed(error)

        case .offlineSearch(let error):
            offlineSearch(error)
           
        case .reloadData:
            print("DEBUG: reloadData")
            updateDiffableDataSource()
       
        }
    }
    // MARK: - Main Flow
    
    private func updateDiffableDataSource(initialLoad: Bool = false, background: UITableView.TableViewBackground = .empty) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, MovieModel>()
        snapshot.appendSections([0])
        snapshot.appendItems(moviesListVM.filteredMovies.elements)
        
        diffableDataSource.apply(snapshot, animatingDifferences: !initialLoad) { [weak self] in
            guard let self = self else { return }
            if !initialLoad {
                isFetchingMoreData = false
            }
            
            tableView.configure(backgroundView: diffableDataSource.numberOfItems == 0 ? background : .none)
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
            isPullToRefreshRunning = false
            finishPullToRefreshAnimationIfNeeded()
        } else {
            progressHUD.dismiss()
        }
        if moviesListVM.filteredMovies.count == 0 {
            tableView.tableFooterView = nil
        } else {
            tableView.tableFooterView = tableFooterLoadingView
        }
        
        
        updateDiffableDataSource(initialLoad: true)
        
        if isSearchingOffline {
            tableView.tableHeaderView = nil
            isSearchingOffline = false
        }
    }
    
    private func moreDataLoadingFinished() {
        print("DEBUG: moreDataLoadingFinished")
        updateDiffableDataSource()
        
        if tableViewDragToEnd {
            tableView.tableFooterView = tableFooterLoadingView
            tableViewDragToEnd = false
        }
    }
    
    private func moreDataLoadingFailed(_ error: CustomError) {
        print("DEBUG: moreDataLoadingFailed")
        isFetchingMoreData = false
        if (lastShowedCellIndex == (diffableDataSource.numberOfItems - 1)) && !tableViewDragToEnd {
            showAlertError(message: error.errorMessage)
            tableView.tableFooterView = tableFooterErrorView
            
        } else if tableViewDragToEnd {
            showAlertError(message: error.errorMessage)
        }
    }
    
    private func initialDataLoadingFailed(_ error: CustomError) {
        print("DEBUG: initialDataLoadingFailed")
        if isPullToRefreshRunning {
            finishPullToRefreshAnimationIfNeeded()
            isPullToRefreshRunning = false
        }
        
        if isSearchingOffline {
            tableView.tableHeaderView = nil
            isSearchingOffline = false
        }
        
        progressHUD.dismiss()
        if isSearchingMode {
            tableView.isHidden = false
            updateDiffableDataSource(background: .failedToLoad)
        }
        tableView.configure(backgroundView: diffableDataSource.numberOfItems == 0 ? .failedToLoad : .none)
        tableView.tableFooterView = nil
        showAlertError(message: error.errorMessage)
    }
    
    private func offlineSearch(_ error: CustomError) {
        print("DEBUG: Offline search")
        isSearchingOffline = true
        tableView.tableFooterView = nil
        tableView.tableHeaderView = TableOfflineHeaderView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 60))
        progressHUD.dismiss()
        updateDiffableDataSource()
        showAlertError(message: error.errorMessage)
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
        if (indexPath.row > (diffableDataSource.numberOfItems - 10)) && !isFetchingMoreData && !tableViewDragToEnd && !isSearchingOffline {
            isFetchingMoreData = true
            moviesListVM.fetchMoreData()
        }
        
        if indexPath.row == diffableDataSource.numberOfItems {
            tableViewDragToEnd = true
        }
        
        if indexPath.row > lastShowedCellIndex {
            lastShowedCellIndex = indexPath.row
        }
    }
}

// MARK: - UISearchBarDelegate, UISearchControllerDelegate

extension PopMoviesViewController: UISearchControllerDelegate, UISearchBarDelegate {
    
    func willPresentSearchController(_ searchController: UISearchController) {
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
        tableView.isHidden = false
        moviesListVM.searchBarCancelButtonClicked()
    }
}

//MARK: - @IBActions

extension PopMoviesViewController {
    @IBAction func showSortOptionsActionSheet(_ sender: Any) {
        let actionSheet = UIAlertController(title: "Select an Option".localized(), message: nil, preferredStyle: .actionSheet)
        
        // Add actions to the action sheet
        let popularityOption = UIAlertAction(title: SortOption.popularity.title.localized(), style: .default) { [weak self] _ in
            self?.sortMovies(by: .popularity)
        }
        
        let ratingOption = UIAlertAction(title: SortOption.rating.title.localized(), style: .default) { [weak self] _ in
            self?.sortMovies(by: .rating)
        }
        
        let titleOption = UIAlertAction(title: SortOption.title.title.localized(), style: .default) { [weak self] _ in
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
        
        let cancelAction = UIAlertAction(title: "Dismiss".localized(), style: .cancel, handler: nil)
        
        actionSheet.addAction(popularityOption)
        actionSheet.addAction(ratingOption)
        actionSheet.addAction(titleOption)
        actionSheet.addAction(cancelAction)
        
        // Present the action sheet
        present(actionSheet, animated: true, completion: nil)
    }
}

