//
//  MenuListReducer.swift
//  mixmax
//
//  Created by Vinh Nguyen on 4/5/18.
//  Copyright © 2018 Vinh Nguyen. All rights reserved.
//


import Foundation
import ReactiveReSwift
import RxSwift

let menuListReducer: Reducer<MenuListState> = { action, state in
    var state = state
    if let action = action as? MenuAddCloudAction {
        state.clouds?.append(action.cloud)
    }
    
    return state
}
