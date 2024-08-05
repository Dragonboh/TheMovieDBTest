//
//  PopMoviesViewController.swift
//  TheMovieDBTest
//
//  Created by admin on 04.08.2024.
//

import UIKit
import JGProgressHUD

enum MovieListState {
    case initialDataLoadingStart
    case initialDataLoadingFinished
    case moreDataLoadingStart
    case moreDataLoadedFinished
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
    private var isPullToRefreshRunning = false
    private var tableViewDragToEnd = false
    private var isFetchingMoreData = false
    private var isSearching = false
    
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
            initialDataLoadingFinished()
            
        case .moreDataLoadingStart:
            startInfinitiveScroll()
            
        case .moreDataLoadedFinished:
            updateDiffableDataSource()
            stopInfinitiveScroll()
    
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
        
        if isSearching {
            searchBarSearchButtonClicked(searchController.searchBar)
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
        
        if isSearching {
            tableView.isHidden = false
        }
        
        updateDiffableDataSource(initialLoad: true)
    }
    
    private func handleError(errorMessage: String) {
        if isPullToRefreshRunning {
            finishPullToRefreshAnimationIfNeeded()
        }
        
        if tableViewDragToEnd {
            stopInfinitiveScroll()
            showAlertError(message: errorMessage)
            isFetchingMoreData = false
            return
        }
        
        if isFetchingMoreData {
            isFetchingMoreData = false
            return
        }
        
        showAlertError(message: errorMessage)
        progressHUD.dismiss()
        tableView.configure(backgroundView: diffableDataSource.numberOfItems == 0 ? .failedToLoad : .none)
//        tableView.isHidden = false
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

extension PopMoviesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        moviesListVM.didSelectRowAt(indexPath)
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        print("Will DIsplay: ", indexPath.row)
    }
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        print("scroll: willDisplayFooterView")
    }
}

// MARK: - UIScrollViewDelegate

// TODO: need fix dont work when very fast scrollling

extension PopMoviesViewController: UIScrollViewDelegate {
    private func offset(_ scrollView: UIScrollView) -> Double {
        let offset = scrollView.contentOffset.y
        let contentHeight = tableView.contentSize.height
        let onScreen = scrollView.frame.size.height
        let counter = contentHeight - offset - onScreen
        
        return counter
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isFetchingMoreData || diffableDataSource.isEmpty {
            return
        }
        
        let offset = offset(scrollView)
        print(offset)
        if (offset < lastScrollOffset) && (offset < 3000) && (offset > 0) {
            isFetchingMoreData = true
            fetchMoreData(endDragging: false)
            lastScrollOffset = offset
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if isFetchingMoreData || diffableDataSource.isEmpty {
            return
        }

        let offset = offset(scrollView)
        if offset < 0 {
            isFetchingMoreData = true
            fetchMoreData(endDragging: true)
        }
    }
}

// MARK: - UISearchBarDelegate, UISearchControllerDelegate

extension PopMoviesViewController: UISearchControllerDelegate, UISearchBarDelegate {
    
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
        print("DEBUG: searchBarCancelButtonClicked")
        isSearching = false
        tableView.isHidden = false
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
