//
//  MenuTableViewCell.swift
//  mixmax
//
//  Created by Vinh Nguyen on 4/3/18.
//  Copyright © 2018 Vinh Nguyen. All rights reserved.
//

import UIKit

class MenuTableViewCell: UITableViewCell {
    
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var menuImageView: UIImageView!

    static var reuseIdentifier: String { return "MenuTableViewCell" }
    
    fileprivate(set) var viewModel: MenuCellViewModel! {
        didSet {
            titleLabel.text = viewModel.title
            menuImageView.image = UIImage(named: viewModel.imageName)
        }
    }
    
    static func dequeueReusableCell(tableView: UITableView) -> MenuTableViewCell? {
        
        return tableView.dequeueReusableCell(withIdentifier: MenuTableViewCell.reuseIdentifier) as? MenuTableViewCell
    }
}

extension MenuTableViewCell: DisplaysMenu {
    func display(menuCellViewModel viewModel: MenuCellViewModel) {
        self.viewModel = viewModel
    }
}
