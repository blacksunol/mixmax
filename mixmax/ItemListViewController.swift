//
//  ItemListViewController.swift
//  mixmax
//
//  Created by Vinh Nguyen on 4/25/17.
//  Copyright © 2017 Vinh Nguyen. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReactiveReSwift

class ItemListViewController: UIViewController {
    
    @IBOutlet weak var itemListCollectionView: UICollectionView!
    
    @IBOutlet weak var settingButton: UIButton!
    
    fileprivate var items = [Item]()
    
    var item: Item?
    
    let cloudClient = CloudClient()
    
    private let disposeBag = SubscriptionReferenceBag()
    private let disposeBag2 = DisposeBag()

    private let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    private let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        cloudClient.downloader.activeDownloads.asObservable().subscribe { [weak self] activeDownloads in
            
            activeDownloads.forEach {

                let download = $0.value
                let index = self?.items.index { item in
            
                    item.track.url == download.urlString
                }

                if let index = index {

                    self?.items[index].track.localUrl = download.destinationUrl
                }
            }
            
            let indices = activeDownloads.map { activeDownload in
                (self?.items.index(where: { item in
                    item.track.url ==  activeDownload.value.urlString
                }), activeDownload.value)
                }.filter { $0.0 != nil }
         
            
            DispatchQueue.main.async {
                
                let indexpaths = indices.flatMap { index in
                    (IndexPath(item: index.0! , section: 0), index.1) }
                
                let cells = indexpaths.map { (self?.itemListCollectionView.cellForItem(at: $0.0) as? ItemListFileCell, $0.1)  }
                cells.forEach { cell in
                    
                    var viewModel = cell.0?.viewModel
                    viewModel?.isDownloadHidden = cell.1.isDownloading
                    cell.0?.display(viewModel: viewModel!)
                    
                    cell.0?.progressView.progress = cell.1.progress
                    print("#isDownloading = \(cell.1.isDownloading)")
                }
            }
        }
        
        
        configureCollectionView()
        activityIndicator.hidesWhenStopped = true
        self.view.addSubview(activityIndicator)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)])
        loadItems()
        observeSettings()
    }
    
    @objc private func loadItems() {
        
        disposeBag += itemStore.observable.asObservable().map { $0.cloud }.distinctUntilChanged { $0 == $1 }.subscribe { [weak self] cloud in
            guard let weakSelf = self else { return }
            guard let cloud = cloud else { return }
            weakSelf.activityIndicator.startAnimating()
            print("#itemStore")
            if cloud == .none {
                weakSelf.settingButton.isHidden = false
            } else {
                weakSelf.settingButton.isHidden = true
            }
            
            weakSelf.cloudClient.callItems(from: weakSelf.item, cloud: cloud) {  (items) in
                weakSelf.title = cloud.rawValue
                weakSelf.activityIndicator.stopAnimating()
                weakSelf.items = items.filter { $0.kind == .audio || $0.kind == .folder }
                weakSelf.itemListCollectionView.reloadSections(IndexSet(integer: 0))
                weakSelf.refreshControl.endRefreshing()
            }
        }

    }
    
    private func configureCollectionView() {
        prepareNibs()
        configureRefreshControl()
    }
    
    private func observeSettings() {
        
//        disposeBag += menuStore.observable.asObservable().map { $0.feature }.distinctUntilChanged { $0 == $1 }.skip(1).subscribe { _ in
//            self.navigationController?.popToRootViewController(animated: false)
//            let storyboard = UIStoryboard(name: "SettingViewController", bundle: nil)
//            if let vc = storyboard.instantiateViewController(withIdentifier :"SettingViewController") as? SettingViewController {
//                self.navigationController?.pushViewController(vc, animated: true)
//            }
//        }
        
        let vc = self.slideMenuController()?.rightViewController as! MenuViewController
        vc.currentFeature.asObservable().skip(1).subscribe(onNext: { feature in
            self.navigationController?.popToRootViewController(animated: false)
            let storyboard = UIStoryboard(name: "SettingViewController", bundle: nil)
            if let vc = storyboard.instantiateViewController(withIdentifier :"SettingViewController") as? SettingViewController {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }).disposed(by: disposeBag2)
    }
    
    private func configureRefreshControl() {
        itemListCollectionView.alwaysBounceVertical = true
        refreshControl.addTarget(self, action: #selector(loadItems), for: .valueChanged)
        itemListCollectionView.addSubview(refreshControl)
    }
    
    private func prepareNibs() {
        itemListCollectionView.register(UINib(nibName: "ItemListCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ItemListCollectionViewCell")
        itemListCollectionView.register(UINib(nibName: "ItemListFileCell", bundle: nil), forCellWithReuseIdentifier: "ItemListFileCell")
    }
    
    
    @IBAction func menuButtonTapped(_ sender: Any) {
        
        slideMenuController()?.openRight()
    }
    
    @IBAction func settingButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "SettingViewController", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier :"SettingViewController") as? SettingViewController {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}

extension ItemListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return items.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let item = items[indexPath.row]

        switch item.kind {
            
        case .audio, .unknow :
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemListFileCell",
                                                          for: indexPath) as! ItemListFileCell
            cell.display(viewModel: ItemListFileCellViewModel(item: item))
            cell.delegate = self
            return cell
        case .folder:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemListCollectionViewCell",
                                                          for: indexPath) as! ItemListCollectionViewCell
        
            cell.configure(item: item)
            return cell
        
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let item = items[indexPath.row]
        
        print("#path = \(String(describing: item.localPath))")
        switch item.kind {
        case .audio:
            let storyboard = UIStoryboard(name: "PlayerViewController", bundle: nil)
            if let playerViewController = storyboard.instantiateViewController(withIdentifier :"PlayerViewController") as? PlayerViewController {

                playerViewController.item = item
                playerViewController.items = items
                present(playerViewController, animated: true)
            }
        case .folder:
            if let itemListViewController = UIStoryboard.instantiateViewController(storyboard: "ItemListViewController") as? ItemListViewController {
                let item = items[indexPath.row]
                itemListViewController.item = item
                navigationController?.pushViewController(itemListViewController, animated: true)
            }
        case .unknow: break
        }
    }
}

extension ItemListViewController : ItemListFileCellDelegate {
    
    func downloadTapped(_ cell: ItemListFileCell) {
        guard let indexPath = itemListCollectionView.indexPath(for: cell) else { return }
        let item = items[indexPath.row]
        cloudClient.download(item: item)

        
        
    }
    
    func removeTapped(_ cell: ItemListFileCell) {
        
        guard let indexPath = itemListCollectionView.indexPath(for: cell) else { return }
        var item = items[indexPath.row]
        cloudClient.removeDownload(item: item) { url in
            
            item.track.localUrl = nil
            items[indexPath.row] = item
            itemListCollectionView.reloadItems(at: [indexPath])
        }
        
    }
}

// MARK: - URLSessionDelegate

extension ItemListViewController: URLSessionDelegate {
    
    // Standard background session handler
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        
        DispatchQueue.main.async {
            
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
                let completionHandler = appDelegate.backgroundSessionCompletionHandler {
                appDelegate.backgroundSessionCompletionHandler = nil
                completionHandler()
            }
        }
    }
    
}

extension UIStoryboard {
    
    class func instantiateViewController(storyboard name: String) -> UIViewController? {
        
        let storyboard = UIStoryboard(name: name, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier :name)
    }
}
