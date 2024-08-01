//
//  MoviePosterCell.swift
//  TheMovieDBTest
//
//  Created by admin on 31.07.2024.
//

import UIKit

class MoviePosterCell: UITableViewCell {

    @IBOutlet weak var moviePosterImageView: UIImageView!
    
    private var imageName: String? {
        didSet {
            loadImage()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        self.contentView.autoresizingMask = .flexibleHeightr
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(imagePath: String?) {
        imageName = imagePath
    }
    
    private func loadImage() {
        guard let urlImageName = imageName else { return }
        
        let url = URL(string: "https://image.tmdb.org/t/p/original/\(urlImageName)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let imageTask = URLSession.shared.dataTask(with: request) { [weak self] data, responce, error in
            if let error = error {
                print("DEBUG: error in getting popular movies, error: \(error.localizedDescription)")
                return
            }
            
            guard let _ = responce as? HTTPURLResponse else {
                print("DEBUG: bad response")
                return
            }
            
            guard let data = data else {
                print("DEBUG: no data")
                return
            }
            
            guard let image = UIImage(data: data) else {
                print("DEBUG: cannot decode image")
                return
            }
            
            if urlImageName == self?.imageName {
                DispatchQueue.main.async { [weak self] in
                    self?.moviePosterImageView.image = image
                }
            }
        }
        imageTask.resume()
    }

}
