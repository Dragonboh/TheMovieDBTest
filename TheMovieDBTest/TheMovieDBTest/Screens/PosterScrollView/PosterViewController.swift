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
    
    override func viewWillAppear(_ animated: Bool) {
        updateConstraintsForSize(view.bounds.size)
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
        guard let urlImagePath = imagePath else {
            assertionFailure("imagePath bad configured")
            return
        }
        let url = URL(string: "https://image.tmdb.org/t/p/w780/\(urlImagePath)")
        posterImageView.kf.setImage(with: url, placeholder: UIImage(systemName: "photo.fill"))
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
        
        let xOffset = max(0, (size.width - posterImageView.frame.width) / 2)
        imageViewLeadingConstraint.constant = xOffset	
        imageViewTrailingConstraint.constant = xOffset
        
        view.layoutIfNeeded()
    }
}
