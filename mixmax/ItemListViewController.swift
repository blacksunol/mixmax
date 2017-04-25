//
//  ItemListViewController.swift
//  mixmax
//
//  Created by Vinh Nguyen on 4/25/17.
//  Copyright © 2017 Vinh Nguyen. All rights reserved.
//

import UIKit

class ItemListViewController: UIViewController {
    
    @IBOutlet weak var itemListCollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareNibs()
    }
    
    private func prepareNibs() {
        itemListCollectionView.register(ItemListCollectionViewCell.self, forCellWithReuseIdentifier: "ItemListCollectionViewCell")
    }
    
    
}

extension ItemListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemListCollectionViewCell",
                                                      for: indexPath) as! ItemListCollectionViewCell
        cell.backgroundColor = UIColor.green
        return cell
    }
    
    
}
