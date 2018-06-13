//
//  ViewController.swift
//  MusicPlayerTransition
//
//  Created by xxxAIRINxxx on 2015/08/27.
//  Copyright (c) 2015 xxxAIRINxxx. All rights reserved.
//

import UIKit
import ARNTransitionAnimator
import RxSwift
import RxCocoa

final class ViewController: UIViewController {
    
    @IBOutlet fileprivate(set) weak var containerView : UIView!
    @IBOutlet fileprivate(set) weak var waveformImageView : UIImageView!
    @IBOutlet fileprivate(set) weak var miniPlayerView : LineView!
    @IBOutlet fileprivate(set) weak var miniPlayerButton : UIButton!
    @IBOutlet fileprivate(set) weak var songLabel : UILabel!
    @IBOutlet fileprivate(set) weak var artistLabel: UILabel!
    
    private var animator : ARNTransitionAnimator?
    fileprivate var modalVC : PlayerViewController!
    
    let disposeBag = DisposeBag()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        miniPlayerView.isHidden = true
        
        let storyboard = UIStoryboard(name: "PlayerViewController", bundle: nil)
        self.modalVC = storyboard.instantiateViewController(withIdentifier: "PlayerViewController") as? PlayerViewController
        self.modalVC.modalPresentationStyle = .overCurrentContext
        
        let color = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 0.3)
        self.miniPlayerButton.setBackgroundImage(self.generateImageWithColor(color), for: .highlighted)
        
        print("ViewController viewWillAppear")

        let image = UIImage.gifImageWithName("wave")
        waveformImageView.image = image
        self.setupAnimator()
    }
    

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("ViewController viewWillAppear")
        self.setupAnimator()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        print("ViewController viewWillDisappear")
        self.setupAnimator()
    }
    
    func setupAnimator() {
        let animation = MusicPlayerTransitionAnimation(rootVC: self, modalVC: self.modalVC)
        animation.completion = { [weak self] isPresenting in
            if isPresenting {
                print("if isPresenting")
                guard let _self = self else { return }
                let modalGestureHandler = TransitionGestureHandler(targetView: _self.modalVC.view, direction: .bottom)
                modalGestureHandler.panCompletionThreshold = 15.0
                _self.animator?.registerInteractiveTransitioning(.dismiss, gestureHandler: modalGestureHandler)
            } else {
                print("!if isPresenting")
                self?.setupAnimator()
            }
        }
        
        let gestureHandler = TransitionGestureHandler(targetView: self.miniPlayerView, direction: .top)
        gestureHandler.panCompletionThreshold = 15.0
        gestureHandler.panFrameSize = self.view.bounds.size

        self.animator = ARNTransitionAnimator(duration: 0.5, animation: animation)
        self.animator?.registerInteractiveTransitioning(.present, gestureHandler: gestureHandler)
        
        self.modalVC.transitioningDelegate = self.animator
    }
    
    @IBAction func tapMiniPlayerButton() {
        self.present(self.modalVC, animated: true, completion: nil)
    }
    
    @IBAction func tapClosePlayerButton() {
        
        modalVC.stopPlaying()

        miniPlayerView.isHidden = true
    }
    
    
    func playItem(item: Item, items: [Item]) {
        
        miniPlayerView.isHidden = false
        modalVC.item = item
        modalVC.items = items
        modalVC.playItem(item: item)
        
        songLabel.text = item.name
        artistLabel.text = "unknow"
        
        modalVC.playerItem.asObservable().skip(1).subscribe { [weak self] in
            
            self?.artistLabel.text = $0?.meta?.album
            self?.songLabel.text = $0?.meta?.name ?? item.name
            }?.disposable.disposed(by: disposeBag)
    }
    
    fileprivate func generateImageWithColor(_ color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
}

