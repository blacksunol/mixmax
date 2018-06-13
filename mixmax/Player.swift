//
//  Player.swift
//  mixmax
//
//  Created by Apple on 4/21/18.
//  Copyright © 2018 Vinh Nguyen. All rights reserved.
//

import AVFoundation
import MediaPlayer
import RxSwift
import RxCocoa

struct PlayerItem {
    
    var url: String?
    
    var playerItem: AVPlayerItem?
    
    var meta: Meta? = Meta()
    
    public struct Meta {
        fileprivate(set) public var name: String?
        fileprivate(set) public var duration: Double?
        fileprivate(set) public var title: String? = "unkown"
        fileprivate(set) public var album: String? = "unkown"
        fileprivate(set) public var artist: String?
        fileprivate(set) public var artwork: UIImage?
    }
    
}

private extension PlayerItem.Meta {
    
    mutating func process(metaItem item: AVMetadataItem) {
        
        switch item.commonKey
        {
        case "title"? :
            title = item.value as? String
        case "albumName"? :
            album = item.value as? String
        case "artist"? :
            artist = item.value as? String
        case "artwork"? :
            processArtwork(fromMetadataItem : item)
        default :
            break
        }
    }
    
    mutating func processArtwork(fromMetadataItem item: AVMetadataItem) {
        guard let value = item.value else { return }
        let copiedValue: AnyObject = value.copy(with: nil) as AnyObject
        
        if let dict = copiedValue as? [AnyHashable: Any] {
            //AVMetadataKeySpaceID3
            if let imageData = dict["data"] as? Data {
                artwork = UIImage(data: imageData)
            }
        } else if let data = copiedValue as? Data{
            //AVMetadataKeySpaceiTunes
            artwork = UIImage(data: data)
        }
    }
}

protocol PlayerDelegate {
    
    func playerWillPlay(playerItem: PlayerItem?)
    func playerDidPlay(playerItem: PlayerItem?)
    func playerProgressing(playerItem: PlayerItem?, progress: Double, duration: Double, time: Double)
}

class Player {
    
    var player: AVPlayer?
    var playerItem: BehaviorRelay<PlayerItem>? = BehaviorRelay(value: PlayerItem())
    var item: Item?
    var items: [Item]?
    
    var playItems: [PlayerItem]?
    
    var removeTimeObserver: Any?
    
    var delegate: PlayerDelegate?
    
    func playItem(item: Item?) {
        
        if let removeTimeObserver = removeTimeObserver {
            player?.removeTimeObserver(removeTimeObserver)
        }
        
        delegate?.playerWillPlay(playerItem: nil)

        player?.pause()
        player = nil
        
        let token = item?.track.token ?? ""
        let header = ["Authorization": "Bearer \(token)"]
        let urlStr = item?.track.playedUrl ?? ""
        guard let url = URL(string: urlStr) else { return }
        
        let asset = AVURLAsset(url: url, options: ["AVURLAssetHTTPHeaderFieldsKey": header])
        asset.loadValuesAsynchronously(forKeys: ["playable"]) { [weak self] in
            
            guard let weakSelf = self else { return }
            var error: NSError? = nil
            let status = asset.statusOfValue(forKey: "playable", error: &error)
        
            var metadata = PlayerItem.Meta()
            metadata.name = item?.name
            for metaItem in asset.commonMetadata {
                
                metadata.process(metaItem: metaItem)
            }
            var playerItem = PlayerItem()
            playerItem.meta = metadata
            weakSelf.delegate?.playerDidPlay(playerItem: playerItem)
            switch status {
                
            case .loaded:
                
                let avplayerItem = AVPlayerItem(asset: asset)
                
                let playerItem2 = PlayerItem(url: item?.track.url, playerItem: avplayerItem, meta: PlayerItem.Meta())
                weakSelf.playerItem?.accept(playerItem2)
                weakSelf.player = AVPlayer(playerItem: weakSelf.playerItem?.value.playerItem)
                
                weakSelf.removeTimeObserver = weakSelf.player?.addPeriodicTimeObserver(forInterval: CMTime.init(value: 1, timescale: 1), queue: .main, using: { [weak self] time in
                    
                    guard let weakSelf = self else { return }
                    if let duration = weakSelf.player?.currentItem?.duration {
                        let duration = CMTimeGetSeconds(duration), time = CMTimeGetSeconds(time)
                        let progress = (time/duration)
                        weakSelf.delegate?.playerProgressing(playerItem: nil, progress: progress, duration: duration, time: time)

                    }})
                
                weakSelf.player?.play()
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
