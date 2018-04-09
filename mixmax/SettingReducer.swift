//
//  SettingReducer.swift
//  mixmax
//
//  Created by Vinh Nguyen on 4/7/18.
//  Copyright © 2018 Vinh Nguyen. All rights reserved.
//

import ReactiveReSwift
import RxSwift

let settingReducer: Reducer<SettingState> = { action, state in
    var state = state
    if let action = action as? SettingActivateAction {
        
    }
    
    return state
}
