//
//  MenuCellViewModel.swift
//  mixmax
//
//  Created by Vinh Nguyen on 4/3/18.
//  Copyright © 2018 Vinh Nguyen. All rights reserved.
//

protocol DisplaysMenu {
    
    func display(settingCellViewModel viewModel: SettingCellViewModel)
}

struct MenuCellViewModel {
    
    let identifier: String
    let title: String
    let imageName: String
}
