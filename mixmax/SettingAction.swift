//
//  SettingAction.swift
//  mixmax
//
//  Created by Vinh Nguyen on 4/7/18.
//  Copyright © 2018 Vinh Nguyen. All rights reserved.
//

import ReactiveReSwift

struct SettingActivateAction: Action {
    
    let cloud: CloudType
    
}

struct SettingInactivateAction: Action {
    
    let cloud: CloudType
    
}
