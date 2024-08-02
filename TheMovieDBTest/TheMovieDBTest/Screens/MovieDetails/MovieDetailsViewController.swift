//
//  MovieDetailsViewController.swift
//  TheMovieDBTest
//
//  Created by admin on 31.07.2024.
//

import UIKit
import JGProgressHUD

enum MovieDetailsState {
    case loadingStart
    case loadingFinished
    case error(String)
}

protocol MoviewDetailsScreenProtocol: AnyObject {
    func updateState(state: MovieDetailsState)
}

class MoviewDetailsViewController: UIViewController, MoviewDetailsScreenProtocol {
    
    @IBOutlet weak var tableView: UITableView!
    
    var movieDetailsVM: MovieDetailsViewModel!
    
    lazy var progressHUD: JGProgressHUD = {
        let hud = JGProgressHUD()
        hud.textLabel.text = "Loading"
        hud.detailTextLabel.text = "Please wait"
        return hud
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = true

        
        fetchData()
    }
    
    func updateState(state: MovieDetailsState) {
        switch state {
        case .loadingStart:
            progressHUD.show(in: view)
        case .loadingFinished:
            print("DEBUG: loading movie details finished")
            progressHUD.dismiss()
            setTitle()
            tableView.isHidden = false
            tableView.reloadData()
        case .error(let errorMessage):
            progressHUD.dismiss()
            showAlertError(message: errorMessage)
            print("Debug: error ucurred: \(errorMessage)")
        }
    }
    
    private func setTitle() {
        navigationItem.title = movieDetailsVM.movieDetails.title
    }
    
    private func fetchData() {
        movieDetailsVM.fetchMovieDetails()
    }
    
    private func showAlertError(message: String) {
        let alertVC = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alertVC, animated: true)
    }
}

extension MoviewDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let movieDetails = movieDetailsVM.movieDetails
        
        switch indexPath.row {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MoviePosterCell", for: indexPath) as? MoviePosterCell else {
                assertionFailure("MoviePosterCell is bad configured")
                return UITableViewCell()
            }
            
            cell.configure(imagePath: movieDetails.posterPath)
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MovieParametersCell", for: indexPath) as? MovieParametersCell else {
                assertionFailure("MovieParametersCell is bad configured")
                return UITableViewCell()
            }
    
            let genres = movieDetails.genres?.map({ genre in
                genre.name
            })
            cell.configure(title: movieDetails.title, country: movieDetails.country, year: movieDetails.releaseDate, genres: genres, rating: movieDetails.rating, isTrailerEnable: !movieDetailsVM.videoKey.isEmpty)
            cell.playTrailerAction = { [weak self] in
                self?.movieDetailsVM.playTrailer()
            }
            return cell
        case 2:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MovieDescriptionCell", for: indexPath) as? MovieDescriptionCell else {
                assertionFailure("MovieDescriptionCell is bad configured")
                return UITableViewCell()
            }
            
            cell.config(description: movieDetails.overview)
            return cell
        default:
            assertionFailure("this table view can't have more than 3 cell")
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        movieDetailsVM.didSelectRowAt(indexPath)
    }
}
