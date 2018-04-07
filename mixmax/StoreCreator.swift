//
//  StoreCreator.swift
//  mixmax
//
//  Created by Vinh Nguyen on 4/5/18.
//  Copyright © 2018 Vinh Nguyen. All rights reserved.
//


import ReactiveReSwift
import RxSwift

let middleware = Middleware<MenuListState>().sideEffect { _, _, action in
    print("Received action:")
    }.map { _, action in
        print(action)
        return action
}

let mainStore = Store(
    reducer: menuListReducer,
    observable: ObservableProperty(MenuListState(clouds:[])),
    middleware: middleware
)

