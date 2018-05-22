//
//  Player.swift
//  mixmax
//
//  Created by Apple on 4/21/18.
//  Copyright © 2018 Vinh Nguyen. All rights reserved.
//

import AVFoundation
import MediaPlayer

class PlayerItem {
    
}

protocol PlayerDelegate {
    
    func playerStartPlaying()
    func playerProgressing(progress: Double, duration: Double, time: Double)
}

class Player {
    
    fileprivate var player: AVPlayer?
    var item: Item?
    var items: [Item]?
    
    var delegate: PlayerDelegate?
    
    func playItem(item: Item?) {
        delegate?.playerStartPlaying()

        player?.pause()
        player = nil
        
        
        
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
                
                self.player?.addPeriodicTimeObserver(forInterval: CMTime.init(value: 1, timescale: 1), queue: .main, using: { [weak self] time in
                    guard let weakSelf = self else { return }
                    if let duration = weakSelf.player?.currentItem?.duration {
                        let duration = CMTimeGetSeconds(duration), time = CMTimeGetSeconds(time)
                        let progress = (time/duration)
                        weakSelf.delegate?.playerProgressing(progress: progress, duration: duration, time: time)
                    }})
                self.player?.play()
            case .failed: break
            case .cancelled: break
            default: break
                
            }
        }
    }
    
    @objc func pause() {
        
        player?.pause()
    }
    
    @objc func play() {
        
        player?.play()
    }
    
    @objc func playNext () {
        
        let index = items?.index {
            $0.track.url == self.item?.track.url
            } ?? 0
        let nextIndex = index + 1
        if nextIndex < (items?.count)! {
            
            item = items?[nextIndex]
            playItem(item: item)
        }
    }
    
    @objc func playPrevious() {
        
        let index = items?.index {
            $0.track.url == self.item?.track.url
            } ?? 0
        let previousIndex = index - 1
        if previousIndex >= 0 {
            item = items?[previousIndex]
            playItem(item: item)
        }
    }
    
    func seek(toValue: Float) {
        
        if let duration = player?.currentItem?.asset.duration.seconds {
            let seconds: Int = Int(Double(toValue) * duration)
            player?.seek(to: CMTimeMake(Int64(seconds), 1))
            player?.play()
        }

    }
}
