//
//  Poster.swift
//  TheMovieDBTest
//
//  Created by admin on 06.08.2024.
//
import UIKit

class PosterViewController: UIViewController {
    
    private var scrollView: UIScrollView!
    private var imageView: UIImageView!
    private var imageViewBottomConstraint: NSLayoutConstraint!
    private var imageViewLeadingConstraint: NSLayoutConstraint!
    private var imageViewTopConstraint: NSLayoutConstraint!
    private var imageViewTrailingConstraint: NSLayoutConstraint!
    
    // can be .scaleAspectFill or .scaleAspectFit
    private var fitMode: UIView.ContentMode = .scaleAspectFit
    
    // if fitMode is .scaleAspectFit, allowFullImage is ignored
    // if fitMode is .scaleAspectFill, image will start zoomed to .scaleAspectFill
    //  if allowFullImage is false, image will zoom back to .scaleAspectFill if "pinched in"
    //  if allowFullImage is true, image can be "pinched in" to see the full image
    private var allowFullImage: Bool = true
    private let imagePath: String
        
    init(imagePath: String) {
        self.imagePath = imagePath
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("use init(imagePath: String) instead")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let url = URL(string: "https://image.tmdb.org/t/p/w1280\(imagePath)") else { return }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(closeSheet))
        
        if let sheet = navigationController?.sheetPresentationController {
            sheet.prefersGrabberVisible = true
        }
        
        setUpViews()
        
        imageView.kf.setImage(with: url)
    }
    
    private func setUpViews() {
        scrollView = UIScrollView()
        imageView = UIImageView()
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.contentMode = .scaleAspectFill
        
        scrollView.addSubview(imageView)
        view.addSubview(scrollView)
        view.backgroundColor = .systemBackground
        scrollView.backgroundColor = .gray
        
        configureConstraints()
       
        scrollView.delegate = self
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 5.0
    }
    
    private func configureConstraints() {
        // respect safe area
        let g = view.safeAreaLayoutGuide
        
        imageViewTopConstraint = imageView.topAnchor.constraint(equalTo: scrollView.topAnchor)
        imageViewBottomConstraint = imageView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        imageViewLeadingConstraint = imageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor)
        imageViewTrailingConstraint = imageView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor)

        NSLayoutConstraint.activate([
            
            scrollView.topAnchor.constraint(equalTo: g.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: g.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: g.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: g.trailingAnchor),

            imageViewTopConstraint,
            imageViewBottomConstraint,
            imageViewLeadingConstraint,
            imageViewTrailingConstraint,
            
        ])
    }

    @objc
    private func closeSheet() {
        dismiss(animated: true)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            self.updateMinZoomScaleForSize(size, shouldSize: (self.scrollView.zoomScale == self.scrollView.minimumZoomScale))
            self.updateConstraintsForSize(size)
        }, completion: {
            _ in
            print("transition")
        })
    }
    
    override func viewDidLayoutSubviews() {
        updateMinZoomScaleForSize(scrollView.bounds.size)
        updateConstraintsForSize(scrollView.bounds.size)
        
        if fitMode == .scaleAspectFill {
            centerImageView()
        }
    }
    
    private func updateMinZoomScaleForSize(_ size: CGSize, shouldSize: Bool = true) {
        guard let img = imageView.image else {
            return
        }
        
        var bShouldSize = shouldSize
        
        let widthScale = size.width / img.size.width
        let heightScale = size.height / img.size.height
        
        var minScale = min(widthScale, heightScale)
        let startScale = max(widthScale, heightScale)
        
        if fitMode == .scaleAspectFill && !allowFullImage {
            minScale = startScale
        }
        
        if scrollView.zoomScale < minScale {
            bShouldSize = true
        }
        
        scrollView.minimumZoomScale = minScale
        if bShouldSize {
            scrollView.zoomScale = fitMode == .scaleAspectFill ? startScale : minScale
        }
    }

    private func centerImageView() -> Void {
        let yOffset = (scrollView.frame.size.height - imageView.frame.size.height) / 2
        let xOffset = (scrollView.frame.size.width - imageView.frame.size.width) / 2
        scrollView.contentOffset = CGPoint(x: -xOffset, y: -yOffset)
    }
    
    private func updateConstraintsForSize(_ size: CGSize) {
        let yOffset = max(0, (size.height - imageView.frame.height) / 2)
        imageViewTopConstraint.constant = yOffset
        imageViewBottomConstraint.constant = yOffset
        
        let xOffset = max(0, (size.width - imageView.frame.width) / 2)
        imageViewLeadingConstraint.constant = xOffset
        imageViewTrailingConstraint.constant = xOffset
        
        view.layoutIfNeeded()
    }
}

extension PosterViewController: UIScrollViewDelegate {
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateConstraintsForSize(scrollView.bounds.size)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
