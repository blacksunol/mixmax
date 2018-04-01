//
//  ItemListViewController.swift
//  mixmax
//
//  Created by Vinh Nguyen on 4/25/17.
//  Copyright © 2017 Vinh Nguyen. All rights reserved.
//

import UIKit
import RxSwift

class ItemListViewController: UIViewController {
    
    @IBOutlet weak var itemListCollectionView: UICollectionView!
    
    fileprivate var items = [Item]()
    
    var item = Item()
    
    private let cloudService = CloudService()
    
    private let disposeBag = DisposeBag()
    
    private let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.hidesWhenStopped = true
        self.view.addSubview(activityIndicator)
        
        // Position it at the center of the ViewController.
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)])
        prepareNibs()
        loadItems()
        observeSettings()
    }
    
    private func loadItems() {
        
        let vc = self.slideMenuController()?.rightViewController as! MenuViewController
        vc.currentCloud.asObservable().subscribe(onNext: { cloudType in
            
            self.activityIndicator.startAnimating()

            self.cloudService.callItems(from: self.item, cloudType: cloudType) { [weak self] (items) in
                guard let weakSelf = self else { return }
                weakSelf.activityIndicator.stopAnimating()
                weakSelf.items = items
                weakSelf.itemListCollectionView.reloadSections(IndexSet(integer: 0))
            }
        }).disposed(by: disposeBag)
    }
    
    private func observeSettings() {
        
        let vc = self.slideMenuController()?.rightViewController as! MenuViewController
        vc.currentFeature.asObservable().skip(1).subscribe(onNext: { feature in
            let storyboard = UIStoryboard(name: "SettingViewController", bundle: nil)
            if let vc = storyboard.instantiateViewController(withIdentifier :"SettingViewController") as? SettingViewController {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }).disposed(by: disposeBag)
    }
    
    private func prepareNibs() {
        itemListCollectionView.register(UINib(nibName: "ItemListCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ItemListCollectionViewCell")
    }
    
}

extension ItemListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemListCollectionViewCell",
                                                      for: indexPath) as! ItemListCollectionViewCell
        let item = items[indexPath.row]
        cell.configure(item: item)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        if item.kind == "file" {
            self.item = item
            let storyboard = UIStoryboard(name: "PlayerViewController", bundle: nil)
            if let playerViewController = storyboard.instantiateViewController(withIdentifier :"PlayerViewController") as? PlayerViewController {
                playerViewController.item = item
                present(playerViewController, animated: true)
            }
            
            return
        }
        
        if let itemListViewController = UIStoryboard.instantiateViewController(storyboard: "ItemListViewController") as? ItemListViewController {
            let item = items[indexPath.row]
            itemListViewController.item = item
            navigationController?.pushViewController(itemListViewController, animated: true)
        }
    }
}

extension UIStoryboard {
    class func instantiateViewController(storyboard name: String) -> UIViewController? {
        let storyboard = UIStoryboard(name: name, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier :name)
    }
}


