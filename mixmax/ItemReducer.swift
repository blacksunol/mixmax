//
//  ItemReducer.swift
//  mixmax
//
//  Created by Vinh Nguyen on 4/13/18.
//  Copyright © 2018 Vinh Nguyen. All rights reserved.
//

import ReactiveReSwift

let itemReducer: Reducer<ItemState> = { action, state in
    
    var state = state
    if let action = action as? ItemAction {
        state = ItemState(currentItem: action.currentItem, cloud: action.cloud)
    }
    
    return state
}

