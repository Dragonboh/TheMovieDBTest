//
//  YouTubeVideoPlayerViewController.swift
//  TheMovieDBTest
//
//  Created by admin on 01.08.2024.
//

import UIKit
import YouTubeiOSPlayerHelper

class YouTubeVideoPlayerViewController: UIViewController {
    
    @IBOutlet weak var playerView: YTPlayerView!
    var videoId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let videoId = videoId else {
            assertionFailure("VideoId is bad cunfigured")
            return
        }

        playerView.load(withVideoId: videoId)
    }
}
