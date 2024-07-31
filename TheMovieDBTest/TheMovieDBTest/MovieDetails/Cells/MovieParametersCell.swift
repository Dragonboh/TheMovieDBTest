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

}
