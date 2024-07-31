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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(title: String?, country: [String]?, year: String?, genres: [String]?, rating: Double?) {
        moviewTitleLabel.text = title
        
        var coutryYearString = ""
        
        if let country = country {
            coutryYearString = country.joined(separator: ", ")
        }
        coutryYearString.append(" ")
        coutryYearString.append(year ?? "")
        countryYearLabel.text = coutryYearString
        
        if let genres = genres {
            genresLabel.text = genres.joined(separator: ", ")
        }
        
        ratingLabel.text = "\(rating ?? 0.0)"
    }

}
