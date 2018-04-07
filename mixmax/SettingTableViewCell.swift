//
//  SettingTableViewCell.swift
//  mixmax
//
//  Created by Vinh Nguyen on 3/20/18.
//  Copyright © 2018 Vinh Nguyen. All rights reserved.
//

import UIKit

class SettingTableViewCell: UITableViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var loginStateLabel: UILabel!
    
    fileprivate(set) var viewModel: SettingCellViewModel! {
        didSet {
            titleLabel.text = viewModel.title
            iconImageView.image = UIImage(named: viewModel.imageName)
            loginStateLabel.text = viewModel.isActive ? "Sign out" : "Sign in"
        }
    }
    
    static var reuseIdentifier: String { return "SettingTableViewCell" }
    
    static func dequeueReusableCell(tableView: UITableView) -> SettingTableViewCell? {
        
        return tableView.dequeueReusableCell(withIdentifier: SettingTableViewCell.reuseIdentifier) as? SettingTableViewCell
    }
}

extension SettingTableViewCell: DisplaysSetting {
    func display(settingCellViewModel viewModel: SettingCellViewModel) {
        self.viewModel = viewModel
    }
}
