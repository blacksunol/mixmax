//
//  PlayerViewController.swift
//  mixmax
//
//  Created by Vinh Nguyen on 3/21/18.
//  Copyright © 2018 Vinh Nguyen. All rights reserved.
//  AVAsynchronousKeyValueLoading
//asset.loadValuesAsynchronously

import UIKit
import AVFoundation
import RxSwift

class PlayerViewController: UIViewController {
    
    var player: AVPlayer?
    var item: Item?
    var items: [Item]? {
        didSet {
            playableItems = items?.filter { $0.isPlayable }
        }
    }
    
    var playableItems: [Item]?
    var timer: Timer?


    override func viewDidLoad() {
        super.viewDidLoad()
        
        let token = item?.track.token ?? ""
        let header = ["Authorization": "Bearer \(token)"]
        let urlStr = item?.track.url ?? ""
        let url = URL(string: urlStr)
        
        let avAsset = AVURLAsset(url: url!, options: ["AVURLAssetHTTPHeaderFieldsKey": header])
        let playerItem = AVPlayerItem(asset: avAsset)
        player = AVPlayer(playerItem: playerItem)
        player?.play()
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateProgressBar), userInfo: nil, repeats: true)
    }
    
    @objc func updateProgressBar(){
        
        let t1 =  player?.currentTime() ?? CMTimeMake(0, 0)
        let t2 =  player?.currentItem?.asset.duration ?? CMTimeMake(0, 0)

        let current = CMTimeGetSeconds(t1)
        let total =  CMTimeGetSeconds(t2)

        if Int(current) != Int(total){

            let min = Int(current) / 60
            let sec =  Int(current) % 60
            print( "%02d:%02d", min,sec)
            let percent = (current/total)

            print("percent \(percent) - \(current) \(total)")
        }else{
            player?.pause()
            player = nil
            timer?.invalidate()
            timer = nil
        }
        
        
    }
    
    
    @IBAction func pauseTapped(_ sender: UIButton) {
        if sender.isSelected {
            sender.isSelected = false
            player?.play()
        } else {
            sender.isSelected = true
            player?.pause()
        }
    }
    
    @IBAction func playNext(_ sender: Any) {
        let index = playableItems?.index {
            $0.track.url == self.item?.track.url
            } ?? 0
        let nextIndex = index + 1
        print("#nextIndex = \(nextIndex)")
        if nextIndex < (playableItems?.count)! {
            player?.pause()
            player = nil
            timer?.invalidate()
            timer = nil
            item = playableItems?[nextIndex]
            let token = item?.track.token ?? ""
            let header = ["Authorization": "Bearer \(token)"]
            let urlStr = item?.track.url ?? ""
            let url = URL(string: urlStr)
            let avAsset = AVURLAsset(url: url!, options: ["AVURLAssetHTTPHeaderFieldsKey": header])
            let playerItem = AVPlayerItem(asset: avAsset)
            player = AVPlayer(playerItem: playerItem)
            player?.play()
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateProgressBar), userInfo: nil, repeats: true)
        }
    }
    
    
    @IBAction func playBack(_ sender: Any) {
        let index = playableItems?.index {
            $0.track.url == self.item?.track.url
            } ?? 0
        let previousIndex = index - 1
        print("#previousIndex = \(previousIndex)")
        if previousIndex >= 0 {
            player?.pause()
            player = nil
            timer?.invalidate()
            timer = nil
            item = playableItems?[previousIndex]
            let token = item?.track.token ?? ""
            let header = ["Authorization": "Bearer \(token)"]
            let urlStr = item?.track.url ?? ""
            let url = URL(string: urlStr)
            let avAsset = AVURLAsset(url: url!, options: ["AVURLAssetHTTPHeaderFieldsKey": header])
            let playerItem = AVPlayerItem(asset: avAsset)
            player = AVPlayer(playerItem: playerItem)
            player?.play()
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateProgressBar), userInfo: nil, repeats: true)
        }
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        player?.pause()
        player = nil
        timer?.invalidate()
        timer = nil
        dismiss(animated: true, completion: nil)
    }
}

extension PlayerViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playableItems?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = playableItems?[indexPath.row]
        let cell =  UITableViewCell()
        cell.textLabel?.text = item?.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        player?.pause()
        player = nil
        timer?.invalidate()
        timer = nil
        item = playableItems?[indexPath.row]
        let token = item?.track.token ?? ""
        let header = ["Authorization": "Bearer \(token)"]
        let urlStr = item?.track.url ?? ""
        let url = URL(string: urlStr)
        let avAsset = AVURLAsset(url: url!, options: ["AVURLAssetHTTPHeaderFieldsKey": header])
        let playerItem = AVPlayerItem(asset: avAsset)
        player = AVPlayer(playerItem: playerItem)
        player?.play()
        
            
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateProgressBar), userInfo: nil, repeats: true)
        
    }
}
