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
    
    func configure(item: Item) {
        nameLabel.text = item.name
    }
}
