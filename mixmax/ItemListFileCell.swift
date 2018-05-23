//
//  ItemListFileCell.swift
//  mixmax
//
//  Created by Apple on 5/3/18.
//  Copyright © 2018 Vinh Nguyen. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

protocol ItemListFileCellDelegate {
    
    func downloadTapped(_ cell: ItemListFileCell)
    func removeTapped(_ cell: ItemListFileCell)
}

class ItemListFileCell : UICollectionViewCell {
    
    @IBOutlet weak private var nameLabel: UILabel!
    
    @IBOutlet weak var kindImageView: UIImageView!
    
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var removeButton: UIButton!
    
    var delegate: ItemListFileCellDelegate?
    
    fileprivate(set) var viewModel: ItemListFileCellViewModel! {
        
        didSet {
            
            nameLabel.text = viewModel.name
            kindImageView.image = UIImage(named: viewModel.imageName)
            downloadButton.isHidden = viewModel.isDownloadHidden
            removeButton.isHidden = !viewModel.isDownloadHidden
            progressView.progress = viewModel.progress
            progressView.isHidden = viewModel.isProgressHidden
        }
    }
    
    @IBAction func downloadTapped(_ sender: AnyObject) {
        
        delegate?.downloadTapped(self)
    }
    
    @IBAction func removeTapped(_ sender: Any) {
        
        delegate?.removeTapped(self)
    }
}

extension ItemListFileCell: Display {
    
    func display(viewModel: ItemListFileCellViewModel) {
        
        self.viewModel = viewModel
    }
}

protocol Display {
    
    func display(viewModel: ItemListFileCellViewModel)
}

struct ItemListFileCellViewModel {
    
    var name: String?
    var imageName: String
    var isDownloadHidden: Bool {
        didSet {
            
            if !isDownloadHidden { progress = 0 }
        }
    }
    var isProgressHidden: Bool = true
    var progress: Float = 0 {
        didSet {
            
            if progress == 1 {
                self.isProgressHidden = true
            }
        }
    }
    
    init(item: Item) {
        
        self.name = item.name
        let isDownloaded = item.track.localUrl != nil && item.track.localUrl != ""
        if isDownloaded {
            
            self.isDownloadHidden = true
        } else {
            
            self.isDownloadHidden = false
        }
        
        switch item.kind {

        case .audio:
            
            self.imageName = "audio"
        case .folder:
            
            self.imageName = "folder"
        case .unknow:
            
            self.imageName = "unknow"
        }
    }
}
