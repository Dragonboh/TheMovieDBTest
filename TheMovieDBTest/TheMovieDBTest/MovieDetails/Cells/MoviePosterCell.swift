//
//  MoviePosterCell.swift
//  TheMovieDBTest
//
//  Created by admin on 31.07.2024.
//

import UIKit

class MoviePosterCell: UITableViewCell {

    @IBOutlet weak var moviePosterImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        self.contentView.autoresizingMask = .flexibleHeightr
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
