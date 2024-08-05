//
//  PosterViewController.swift
//  TheMovieDBTest
//
//  Created by admin on 01.08.2024.
//

import UIKit
import JGProgressHUD
import Kingfisher

class PosterViewController: UIViewController {
    
    @IBOutlet weak var posterImageView: UIImageView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var imageViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var imageViewLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var imageViewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var imageViewTrailingConstraint: NSLayoutConstraint!
    
    weak var topConstraint: NSLayoutConstraint?
    weak var bottomConstraint: NSLayoutConstraint?
    weak var leftConstraint: NSLayoutConstraint?
    weak var rightConstraint: NSLayoutConstraint?
    
    lazy var progressHUD: JGProgressHUD = {
        let hud = JGProgressHUD()
        hud.textLabel.text = "Loading"
        hud.detailTextLabel.text = "Please wait"
        return hud
    }()
    
    weak var testImageView: UIImageView?
    var imagePath: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
       
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(closeSheet))
        
        if let sheet = navigationController?.sheetPresentationController {
            sheet.prefersGrabberVisible = true
        }
        
        let image = UIImageView(frame: .zero)
        testImageView = image
//        guard let testImageView = testImageView else { return }
        scrollView.addSubview(testImageView!)
        
        testImageView!.translatesAutoresizingMaskIntoConstraints = false
        let topConstraint = testImageView!.topAnchor.constraint(equalTo: scrollView.topAnchor)
        let bottomConstraint = testImageView!.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        let leftConstraint = testImageView!.leftAnchor.constraint(equalTo: scrollView.leftAnchor)
        let rightConstraint = testImageView!.rightAnchor.constraint(equalTo: scrollView.rightAnchor)
        NSLayoutConstraint.activate([topConstraint, bottomConstraint, leftConstraint, rightConstraint])
        
        loadImage()
    }
    
    @objc
    private func closeSheet() {
        dismiss(animated: true)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateMinZoomScaleForSize(view.bounds.size)
    }

    
//    private func updateMinZoomScaleForSize(_ size: CGSize) {
//        let widthScale = size.width / posterImageView.bounds.width
//        let heightScale = size.height / posterImageView.bounds.height
//        let minScale = min(widthScale, heightScale)
//        
//        scrollView.minimumZoomScale = minScale
//        scrollView.zoomScale = minScale
//        scrollView.maximumZoomScale = 1
//    }
    
    private func updateMinZoomScaleForSize(_ size: CGSize) {
        let widthScale = size.width / testImageView!.bounds.width
        let heightScale = size.height / testImageView!.bounds.height
        let minScale = min(widthScale, heightScale)
        
        scrollView.minimumZoomScale = minScale
        scrollView.zoomScale = minScale
        scrollView.maximumZoomScale = 1
    }
    
    private func loadImage() {
//        guard let urlImagePath = imagePath, let url = URL(string: "https://image.tmdb.org/t/p/original\(urlImagePath)") else {
//            return
//        }

//        posterImageView.load(url: url)
        guard let urlImagePath = imagePath else { return }
        let url = URL(string: "https://image.tmdb.org/t/p/original\(urlImagePath)")
        testImageView!.kf.setImage(with: url)
    }
}

extension PosterViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return testImageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateConstraintsForSize(scrollView.bounds.size)
    }
    
    func updateConstraintsForSize(_ size: CGSize) {
        let yOffset = max(0, (size.height - posterImageView.frame.height) / 2)

        topConstraint!.constant = yOffset
        bottomConstraint!.constant = yOffset

        let xOffset = max(0, (size.width - posterImageView.frame.width) / 2)
        rightConstraint!.constant = xOffset
        leftConstraint!.constant = xOffset

        view.layoutIfNeeded()
    }
    
//    func updateConstraintsForSize(_ size: CGSize) {
//        let yOffset = max(0, (size.height - posterImageView.frame.height) / 2)
//       
////        if let navHeihght = navigationController?.navigationBar.frame.height {
////            imageViewTopConstraint.constant = yOffset - navHeihght
////        } else {
////            imageViewTopConstraint.constant = yOffset
////        }
////
//        imageViewTopConstraint.constant = yOffset
//        imageViewBottomConstraint.constant = yOffset
//        
//        let xOffset = max(0, (size.width - posterImageView.frame.width) / 2)
//        imageViewLeadingConstraint.constant = xOffset	
//        imageViewTrailingConstraint.constant = xOffset
//        
//        view.layoutIfNeeded()
//    }
    
//    func updateConstraintsForSize(_ size: CGSize) {
//        let yOffset = max(0, (scrollView.frame.size.height - posterImageView.frame.height) / 2)
//        imageViewTopConstraint.constant = yOffset
//        imageViewBottomConstraint.constant = yOffset
//        
//        let xOffset = max(0, (scrollView.frame.size.width - posterImageView.frame.width) / 2)
//        imageViewLeadingConstraint.constant = xOffset
//        imageViewTrailingConstraint.constant = xOffset
//        
//        view.layoutIfNeeded()
//    }
}

//private extension UIImageView {
//    func load(url: URL) {
//        DispatchQueue.global().async { [weak self] in
//            if let data = try? Data(contentsOf: url) {
//                if let image = UIImage(data: data) {
//                    DispatchQueue.main.async {
//                        self?.image = image
//                    }
//                }
//            }
//        }
//    }
//}
