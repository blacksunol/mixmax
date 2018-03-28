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
    var item = Item()
    var myTimer:Timer!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        let token = item.track.token ?? ""
        let header = ["Authorization": "Bearer \(token)"]
        let url = URL(string: item.track.url!)
        
        let avAsset = AVURLAsset(url: url!, options: ["AVURLAssetHTTPHeaderFieldsKey": header])
        let playerItem = AVPlayerItem(asset: avAsset)
        player = AVPlayer(playerItem: playerItem)
        player?.play()
        
        myTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateProgressBar), userInfo: nil, repeats: true)
    }
    
    @objc func updateProgressBar(){
        
        let t1 =  self.player?.currentTime()
        let t2 =  self.player?.currentItem?.asset.duration
        
        let current = CMTimeGetSeconds(t1!)
        let total =  CMTimeGetSeconds(t2!)
        
        if Int(current) != Int(total){
            
            let min = Int(current) / 60
            let sec =  Int(current) % 60
            print( "%02d:%02d", min,sec)
            let percent = (current/total)
            
            print("percent \(percent) - \(current) \(total)")
        }else{
            player?.pause()
            player = nil
            myTimer.invalidate()
            myTimer = nil
        }
        
        
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        player?.pause()
        dismiss(animated: true, completion: nil)
    }
}
