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
    
    var videoId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let videoId = videoId else {
            assertionFailure("VideoId is bad cunfigured")
            return
        }
        progressHUD.show(in: view)
        playerView.load(withVideoId: videoId)
        playerView.delegate = self
    }
}

extension YouTubeVideoPlayerViewController: YTPlayerViewDelegate {
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        progressHUD.dismiss()
    }
}
