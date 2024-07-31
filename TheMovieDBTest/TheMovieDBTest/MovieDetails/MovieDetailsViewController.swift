//
//  MovieDetailsViewController.swift
//  TheMovieDBTest
//
//  Created by admin on 31.07.2024.
//

import UIKit


class MoviewDetailsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var movieDetailsVM: MovieDetailsViewModel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
    }
    
}

extension MoviewDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MoviePosterCell", for: indexPath) as! MoviePosterCell
        
        return cell
    }
    
    
}
