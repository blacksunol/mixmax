//
//  PlayerViewController.swift
//  mixmax
//
//  Created by Vinh Nguyen on 3/21/18.
//  Copyright © 2018 Vinh Nguyen. All rights reserved.
//  AVAsynchronousKeyValueLoading
//asset.loadValuesAsynchronously
//https://stackoverflow.com/questions/7894979/how-to-show-avplayer-current-play-duration-in-uislider

import UIKit
import AVFoundation
import RxSwift
import RxCocoa

class PlayerViewController: UIViewController {
    
    @IBOutlet weak var progressSlider: UISlider!

    var disposeBag = DisposeBag()
    var player: AVPlayer?
    var item: Item?
    var items: [Item]? {
        didSet {
            playableItems = items?.filter { $0.isPlayable }
        }
    }
    
    var playableItems: [Item]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        playItem(item: item)

        //        progressSlider.rx.value.map{ value -> String in
        //            "\(Int(value * 2000)) $"
        //            }.asObservable().bindTo { _ in
        //                print("#bindTo")
        //            }
        //        progressSlider.rx.value.throttle(0.3, scheduler: MainScheduler.instance).asObservable().subscribe {
        //                print("#subcrible")
        //        }
        
    }
    
    @IBAction func slideUpdated(_ sender: UISlider) {
        let seconds : Int64 = Int64(sender.value)
        let targetTime:CMTime = CMTimeMake(seconds, 1)
        player?.seek(to: targetTime)
        
    }
    
    func playItem(item: Item?) {
        let token = item?.track.token ?? ""
        let header = ["Authorization": "Bearer \(token)"]
        let urlStr = item?.track.url ?? ""
        let url = URL(string: urlStr)
        
        let asset = AVURLAsset(url: url!, options: ["AVURLAssetHTTPHeaderFieldsKey": header])
        asset.loadValuesAsynchronously(forKeys: ["playable"]) {
            
            var error: NSError? = nil
            let status = asset.statusOfValue(forKey: "playable", error: &error)
            switch status {
            case .loaded:
                let playerItem = AVPlayerItem(asset: asset)
                self.player = AVPlayer(playerItem: playerItem)
                let maxValue: Float = Float(CMTimeGetSeconds(playerItem.duration))
                print("maxValue = \(maxValue)")
                self.player?.addPeriodicTimeObserver(forInterval: CMTime.init(value: 1, timescale: 1), queue: .main, using: { time in
                    if let duration = self.player?.currentItem?.duration {
                        let duration = CMTimeGetSeconds(duration), time = CMTimeGetSeconds(time)
                        let progress = (time/duration)
                        self.progressSlider.setValue(Float(progress), animated: true)
                    }})
                self.player?.play()
            case .failed: break
            case .cancelled: break
            default: break
                
            }
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
        if nextIndex < (playableItems?.count)! {
            player?.pause()
            player = nil
            item = playableItems?[nextIndex]
            playItem(item: item)
        }
    }
    
    
    @IBAction func playBack(_ sender: Any) {
        let index = playableItems?.index {
            $0.track.url == self.item?.track.url
            } ?? 0
        let previousIndex = index - 1
        if previousIndex >= 0 {
            player?.pause()
            player = nil
            item = playableItems?[previousIndex]
            playItem(item: item)
        }
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        player?.pause()
        player = nil
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
        item = playableItems?[indexPath.row]
        playItem(item: item)
    }
}
