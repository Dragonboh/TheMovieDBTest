//
//  YouTubeVideoPlayerViewController.swift
//  TheMovieDBTest
//
//  Created by admin on 01.08.2024.
//

import UIKit
import YouTubeiOSPlayerHelper
import JGProgressHUD

class YouTubeVideoPlayerViewController: UIViewController {
    
    @IBOutlet weak var playerView: YTPlayerView!
    
    lazy var progressHUD: JGProgressHUD = {
        let hud = JGProgressHUD()
        return hud
    }()
    
    private var videoId: String
    
    init?(coder: NSCoder, videoId: String) {
        self.videoId = videoId
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("use init?(coder: NSCoder, viewModel: MoviesListViewModel) instead")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressHUD.show(in: view)
        playerView.load(withVideoId: videoId)
        playerView.delegate = self
        
        if let sheet = self.sheetPresentationController {
            sheet.prefersGrabberVisible = true
            sheet.detents = [.large(), .medium()]
            sheet.selectedDetentIdentifier = .medium
        }
    }
}

extension YouTubeVideoPlayerViewController: YTPlayerViewDelegate {
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        progressHUD.dismiss()
    }
}
