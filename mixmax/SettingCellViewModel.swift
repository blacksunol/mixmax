//
//  SettingCellViewModel.swift
//  mixmax
//
//  Created by Vinh Nguyen on 4/7/18.
//  Copyright © 2018 Vinh Nguyen. All rights reserved.
//

protocol DisplaysSetting {
    
    func display(settingCellViewModel viewModel: SettingCellViewModel)
}

struct SettingCellViewModel {
    
    var title: String
    let imageName: String
    let isActive: Bool
}
