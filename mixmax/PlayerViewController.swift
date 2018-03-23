//
//  PlayerViewController.swift
//  mixmax
//
//  Created by Vinh Nguyen on 3/21/18.
//  Copyright © 2018 Vinh Nguyen. All rights reserved.
//

import UIKit
import AVFoundation
import GoogleSignIn


class PlayerViewController: UIViewController {
    
    private var player: AVPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let accessToken = GIDSignIn.sharedInstance().currentUser.authentication.accessToken else {
            return
        }
        
        
        let headers = ["Authorization": "Bearer \(accessToken)"]
        let url = URL(string: "https://www.googleapis.com/drive/v3/files/1siQAS6GbPTvN0xNKejBlyE6VREYa8hKC?alt=media")!
        
      
        let avAsset = AVURLAsset(url: url, options: ["AVURLAssetHTTPHeaderFieldsKey": headers])
        let playerItem = AVPlayerItem(asset: avAsset)
        player = AVPlayer(playerItem: playerItem)
        player?.play()
    }
}
