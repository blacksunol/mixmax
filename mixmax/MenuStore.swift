//
//  StoreCreator.swift
//  mixmax
//
//  Created by Vinh Nguyen on 4/5/18.
//  Copyright © 2018 Vinh Nguyen. All rights reserved.
//


import ReactiveReSwift
import RxSwift

let menuMiddleware = Middleware<MenuListState>().sideEffect { _, _, action in
    print("Received action:")
    }.map { _, action in
        print(action)
        return action
}

let menuStore = Store(
    reducer: menuListReducer,
    observable: Variable(MenuListState(clouds:[], selectedCloud: .none, feature: "")),
    middleware: menuMiddleware
)

