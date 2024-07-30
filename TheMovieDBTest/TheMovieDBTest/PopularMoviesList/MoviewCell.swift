//
//  MoviewCell.swift
//  TheMovieDBTest
//
//  Created by admin on 28.07.2024.
//

import UIKit

class MoviewCell: UITableViewCell {

    @IBOutlet weak var movieImageView: UIImageView!
    @IBOutlet weak var titleAndYearLabel: UILabel!
    @IBOutlet weak var genresLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    
    var imageName: String? {
        didSet {
            loadImage()
        }
    }
    
//    var downloadImageTasks = [String: URLSessionDataTask]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.autoresizingMask = .flexibleHeight
    }
//
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state`
//    }
    
    override func prepareForReuse() {
        movieImageView.image = nil
//        guard let imageName = imageName, let downloadTask = downloadImageTasks[imageName] else { return }
//        downloadTask.cancel()
    }
    

    private func loadImage() {
//        guard let urlImageName = imageName else { return }
//        
//        let url = URL(string: "https://image.tmdb.org/t/p/w780/\(urlImageName)")!
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        
//        let imageTask = URLSession.shared.dataTask(with: request) { [weak self] data, responce, error in
//            if let error = error {
//                print("DEBUG: error in getting popular movies, error: \(error.localizedDescription)")
//                return
//            }
//            
//            guard let _ = responce as? HTTPURLResponse else {
//                print("DEBUG: bad response")
//                return
//            }
//            
//            guard let data = data else {
//                print("DEBUG: no data")
//                return
//            }
//            
//            guard let image = UIImage(data: data) else {
//                print("DEBUG: cannot decode image")
//                return
//            }
//            
//            if urlImageName == self?.imageName {
//                DispatchQueue.main.async { [weak self] in
//                    self?.movieImageView.image = image
//                }
//            }
//        }
//        
////        downloadImageTasks[imageName] = imageTask
//        imageTask.resume()
    }

}
