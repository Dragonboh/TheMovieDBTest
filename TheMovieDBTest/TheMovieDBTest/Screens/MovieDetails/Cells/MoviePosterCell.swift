//
//  MoviePosterCell.swift
//  TheMovieDBTest
//
//  Created by admin on 31.07.2024.
//

import UIKit
import Kingfisher

class MoviePosterCell: UITableViewCell {

    @IBOutlet weak var moviePosterImageView: UIImageView!
    
    func configure(imagePath: String?) {
        guard let imagePath = imagePath else { return }
        let url = URL(string: "https://image.tmdb.org/t/p/w1280/\(imagePath)")
        moviePosterImageView.kf.setImage(with: url, placeholder: UIImage(systemName: "photo.fill"))
    }
}
