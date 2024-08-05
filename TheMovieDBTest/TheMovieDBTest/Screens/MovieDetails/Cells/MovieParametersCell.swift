//
//  MovieParametersCell.swift
//  TheMovieDBTest
//
//  Created by admin on 31.07.2024.
//

import UIKit

class MovieParametersCell: UITableViewCell {

    @IBOutlet weak var moviewTitleLabel: UILabel!
    @IBOutlet weak var countryYearLabel: UILabel!
    @IBOutlet weak var genresLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var playTrailerButton: UIButton!
    @IBOutlet weak var originalTitleLabel: UILabel!
    
    var playTrailerAction: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        resetToDefaults()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func resetToDefaults() {
        moviewTitleLabel.text = " --- "
        originalTitleLabel.text = " --- "
        countryYearLabel.text = " --- "
        genresLabel.text = " --- "
        ratingLabel.text = " -- "
        
        playTrailerButton.isHidden = true
    }
    
    func configure(title: String?, originalTitle: String?, country: [String]?, releaseDate: String?, genres: [String]?, rating: Double?, isTrailerEnable: Bool) {
        
        if let title = title {
            moviewTitleLabel.text = title
        }
        
        if let originalTitle = originalTitle {
            originalTitleLabel.text = "\(originalTitle) (original tiitle)"
        }
        
        var coutryYearString = ""
        
        if let country = country {
            coutryYearString = country.joined(separator: ", ")
        }
        
        if let releaseDate = releaseDate {
            coutryYearString.append(", ")
            coutryYearString.append(releaseDate)
        }
        
        if !coutryYearString.isEmpty {
            countryYearLabel.text = coutryYearString
        }
        
        if let genres = genres {
            genresLabel.text = genres.joined(separator: ", ")
        }
        
        if let rating = rating {
            ratingLabel.text = String(format: "%.1f", rating)
        }
        
        playTrailerButton.isHidden = !isTrailerEnable 
    }

    @IBAction func playTrailer(_ sender: Any) {
        playTrailerAction?()
    }
}
