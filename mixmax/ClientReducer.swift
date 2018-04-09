//
//  ClientReducer.swift
//  mixmax
//
//  Created by Vinh Nguyen on 4/8/18.
//  Copyright © 2018 Vinh Nguyen. All rights reserved.
//

import ReactiveReSwift
import RxSwift

let clientReducer: Reducer<ClientState> = { action, state in
    var state = state
    if let action = action as? LoginAction {
//        state.isFinished = action.isFinished
    }
    
    if let action = action as? LogoutAction {
        //        state.isFinished = action.isFinished
    }
    
    return state
}
