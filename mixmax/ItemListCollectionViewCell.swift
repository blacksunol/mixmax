//
//  ListCollectionViewCell.swift
//  mixmax
//
//  Created by Vinh Nguyen on 4/25/17.
//  Copyright © 2017 Vinh Nguyen. All rights reserved.
//

import UIKit

class ItemListCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak private var nameLabel: UILabel!
    
    @IBOutlet weak var kindImageView: UIImageView!
    
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
}
