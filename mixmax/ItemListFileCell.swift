//
//  ItemListFileCell.swift
//  mixmax
//
//  Created by Apple on 5/3/18.
//  Copyright © 2018 Vinh Nguyen. All rights reserved.
//

import UIKit

protocol ItemListFileCellDelegate {
    
    func downloadTapped(_ cell: ItemListFileCell)
    func cancelTapped(_ cell: ItemListFileCell)
}

class ItemListFileCell : UICollectionViewCell {
    
    @IBOutlet weak private var nameLabel: UILabel!
    
    @IBOutlet weak var kindImageView: UIImageView!
    
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var downloadButton: UIButton!

    var delegate: ItemListFileCellDelegate?

    func configure(item: Item) {
        
        nameLabel.text = item.name
        
        switch item.kind {
            
        case .audio:
            kindImageView.image = UIImage(named: "audio")
        case .folder:
            kindImageView.image = UIImage(named: "folder")
        case .unknow:
            kindImageView.image = UIImage(named: "unknow")
        }
    }
    
    @IBAction func downloadTapped(_ sender: AnyObject) {
        
        delegate?.downloadTapped(self)
    }
}
