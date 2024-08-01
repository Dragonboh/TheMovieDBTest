//
//  PosterViewController.swift
//  TheMovieDBTest
//
//  Created by admin on 01.08.2024.
//

import UIKit
import JGProgressHUD

class PosterViewController: UIViewController {
    
    @IBOutlet weak var posterImageView: UIImageView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTrailingConstraint: NSLayoutConstraint!
    
    lazy var progressHUD: JGProgressHUD = {
        let hud = JGProgressHUD()
        hud.textLabel.text = "Loading"
        hud.detailTextLabel.text = "Please wait"
        return hud
    }()
    
    var imagePath: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        loadImage()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(closeSheet))
        
        if let sheet = navigationController?.sheetPresentationController {
            sheet.prefersGrabberVisible = true
        }
    }
    
    @objc
    private func closeSheet() {
        dismiss(animated: true)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateMinZoomScaleForSize(view.bounds.size)
    }
    
    private func updateMinZoomScaleForSize(_ size: CGSize) {
        let widthScale = size.width / posterImageView.bounds.width
        let heightScale = size.height / posterImageView.bounds.height
        let minScale = min(widthScale, heightScale)
        
        scrollView.minimumZoomScale = minScale
        scrollView.zoomScale = minScale
        scrollView.maximumZoomScale = 1
    }
    
    private func loadImage() {
        guard let urlImageName = imagePath else { return }
        
        let url = URL(string: "https://image.tmdb.org/t/p/original/\(urlImageName)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        progressHUD.show(in: view)
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
            
            DispatchQueue.main.async { [weak self] in
                self?.progressHUD.dismiss()
                self?.posterImageView.image = image
            }
        }
        imageTask.resume()
    } 
}

extension PosterViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return posterImageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateConstraintsForSize(view.bounds.size)
    }
    
    func updateConstraintsForSize(_ size: CGSize) {
        let yOffset = max(0, (size.height - posterImageView.frame.height) / 2)
        imageViewTopConstraint.constant = yOffset
        imageViewBottomConstraint.constant = yOffset
        
        //4
        let xOffset = max(0, (size.width - posterImageView.frame.width) / 2)
        imageViewLeadingConstraint.constant = xOffset	
        imageViewTrailingConstraint.constant = xOffset
        
        view.layoutIfNeeded()
    }
}
