//
//  MoviewCell.swift
//  TheMovieDBTest
//
//  Created by admin on 28.07.2024.
//

import UIKit
import Kingfisher

class MoviewCell: UITableViewCell {

    @IBOutlet weak var movieImageView: UIImageView!
    @IBOutlet weak var titleAndYearLabel: UILabel!
    @IBOutlet weak var genresLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    
    static let identifier = String(describing: MoviewCell.self)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.autoresizingMask = .flexibleHeight
        resettoDefault()
    }
    
    override func prepareForReuse() {
        resettoDefault()
    }
    
    private func resettoDefault() {
        movieImageView.image = UIImage(systemName: "photo.fill")
        ratingLabel.text = "⭐️ --"
        genresLabel.text = "---- "
        titleAndYearLabel.text = "----"
    }
    
    func configure(title: String?, year: String?, rating: Double?, genres: [String]?, imagePath: String?) {
        var titleAndYeartext = ""
        
        if let title = title {
            titleAndYeartext.append(title)
        } else {
            titleAndYeartext.append("-----")
        }
        titleAndYeartext.append("\n")
        titleAndYeartext.append(year ?? "")
        titleAndYearLabel.text = titleAndYeartext
        
        if let rating = rating {
            ratingLabel.text = "⭐️ \(rating)"
        }
        
        if let genres = genres {
            genresLabel.text = genres.joined(separator: ", ")
        }

        guard let imagePath = imagePath else { return }
        let url = URL(string: "https://image.tmdb.org/t/p/w780/\(imagePath)")
        movieImageView.kf.setImage(with: url, placeholder: UIImage(systemName: "photo.fill"))
    }
}
