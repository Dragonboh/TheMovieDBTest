//
//  PopMovieCell.swift
//  TheMovieDBTest
//
//  Created by admin on 04.08.2024.
//

import UIKit

class PopMovieCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var genresLabel: UILabel!
    @IBOutlet weak var moviePosterImageView: UIImageView!
    @IBOutlet weak var ratingLabel: UILabel!
    
    static let identifier = String(describing: PopMovieCell.self)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        resetToDefault()
    }
    
    override func prepareForReuse() {
        resetToDefault()
    }
    
    private func resetToDefault() {
        moviePosterImageView.image = UIImage(systemName: "photo.fill")
        ratingLabel.text = "--"
        releaseDateLabel.text = "Release date: ---"
        genresLabel.text = "Genres: ---- "
        titleLabel.text = "Title: ----"
    }
    
    func configure(title: String?, releaseDate: String?, rating: Double?, genres: [String]?, imagePath: String?) {
        if let title = title {
            titleLabel.text = title
        }
        
        if let releaseDate = releaseDate {
            releaseDateLabel.text = "Release date: \(releaseDate)"
        }
        
        if let genres = genres {
            genresLabel.text = genres.joined(separator: ", ")
        }
        
        if let rating = rating {
            ratingLabel.text = String(format: "%.1f", rating)
        }

        guard let imagePath = imagePath else { return }
        let url = URL(string: "https://image.tmdb.org/t/p/w342/\(imagePath)")
        moviePosterImageView.kf.setImage(with: url, placeholder: UIImage(systemName: "photo.fill"))
    }
}
