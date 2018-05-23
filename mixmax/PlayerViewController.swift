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
import RxSwift
import RxCocoa
import MediaPlayer

class PlayerViewController: UIViewController {
    
    @IBOutlet weak var progressSlider: UISlider!
    
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    
    fileprivate let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)

    var disposeBag = DisposeBag()

    fileprivate var player: Player?
    
    var item: Item?
    var items: [Item]? {
        
        didSet {
            
            playableItems = items?.filter { $0.isPlayable }
        }
    }
    
    var playableItems: [Item]?
    let slider = UISlider()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        remoteControl()
        
        activityIndicator.hidesWhenStopped = true
        self.view.addSubview(activityIndicator)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)])
        
        
        NotificationCenter.default.rx.notification(Notification.Name.AVPlayerItemDidPlayToEndTime)
            .asObservable().subscribe(onNext: { [weak self] notification in
                guard let weakSelf = self else { return }
                weakSelf.playNext()
                
            }).disposed(by: disposeBag)
        
        var outValue: Float = 0
        slider.rx.value.subscribe(onNext: { value in
            outValue = value
            print("outValue = \(outValue)")
        }).disposed(by: disposeBag)
        slider.value = 0.3
        
        player = Player()
        
        player?.delegate = self
        
        player?.item = item
        player?.items = playableItems
        
        player?.playItem(item: item)
        
        //        progressSlider.rx.value.map{ value -> String in
        //            "\(Int(value * 2000)) $"
        //            }.asObservable().bindTo { _ in
        //                print("#bindTo")
        //            }
        //        progressSlider.rx.value.throttle(0.3, scheduler: MainScheduler.instance).asObservable().subscribe {
        //                print("#subcrible")
        //        }
        
    }
    
    func remoteControl() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.previousTrackCommand.isEnabled = true;
        commandCenter.previousTrackCommand.addTarget(self, action: #selector(PlayerViewController.playPrevious as (PlayerViewController) -> () -> ()))
        
        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.nextTrackCommand.addTarget(self, action: #selector(PlayerViewController.playNext as (PlayerViewController) -> () -> ()))
        
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget(self, action: #selector(PlayerViewController.play as (PlayerViewController) -> () -> ()))
        
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget(self, action: #selector(PlayerViewController.pause as (PlayerViewController) -> () -> ()))
    }
    
    @IBAction func slideUpdated(_ sender: UISlider) {
        
            player?.seek(toValue: sender.value)
            slider.value = 0.4
            slider.sendActions(for: UIControlEvents.valueChanged)

        
    }
    
    func playItem(item: Item?) {
        
        player?.playItem(item: item)
    }
    
    func populateLabelWithTime(_ label : UILabel, time: Double) {
        guard !(time.isNaN || time.isInfinite) else { return }
        
        let minutes = Int(time / 60)
        let seconds = Int(time) - minutes * 60
        
        label.text = String(format: "%02d", minutes) + ":" + String(format: "%02d", seconds)
    }
    
    func playNext() {
        
        player?.playNext()
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
        
        playNext()
    }
    
    
    @IBAction func playBack(_ sender: Any) {
        
        playPrevious()
    }
    
    func playPrevious() {
        
        player?.playPrevious()
    }
    
    func pause() {
        
        player?.pause()
    }
    
    func play() {
        
        player?.play()
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        
        player?.pause()
        player = nil
        dismiss(animated: true, completion: nil)
    }
}

extension PlayerViewController: PlayerDelegate {
    
    func playerProgressing(progress: Double, duration: Double, time: Double) {
        
        progressSlider.setValue(Float(progress), animated: true)
        populateLabelWithTime(durationLabel, time: duration)
        populateLabelWithTime(timerLabel, time: time)
        activityIndicator.stopAnimating()

    }

    func playerStartPlaying() {
        
        activityIndicator.startAnimating()
        progressSlider.setValue(Float(0), animated: true)
        populateLabelWithTime(durationLabel, time: Double(0))
        populateLabelWithTime(timerLabel, time: Double(0))
        playButton.isSelected = false

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
