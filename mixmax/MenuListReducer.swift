//
//  MenuListReducer.swift
//  mixmax
//
//  Created by Vinh Nguyen on 4/5/18.
//  Copyright © 2018 Vinh Nguyen. All rights reserved.
//


import ReactiveReSwift
import RxSwift
import Foundation

let menuListReducer: Reducer<MenuListState> = { action, state in
    var state = state
    if let action = action as? MenuAddCloudAction {
        state.clouds.append(action.cloud)
    }
    
    if let action = action as? MenuRemoveCloudAction {
        state.clouds = state.clouds.filter { $0 != action.cloud }
    }
    
    if let action = action as? InitCloudsAction {
        state.clouds = action.clouds
        let defaultCloud = UserDefaults.standard.string(forKey: "selectedCloud") ?? ""
        state.selectedCloud = CloudType(rawValue: defaultCloud) ?? CloudType.none
    }
    
    if let action = action as? SelectedCloudAction {
        state.selectedCloud = action.cloud
        UserDefaults.standard.set(action.cloud.rawValue, forKey: "selectedCloud")
    }
    
    return state
}
