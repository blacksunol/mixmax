//
//  ItemStore.swift
//  mixmax
//
//  Created by Vinh Nguyen on 4/13/18.
//  Copyright © 2018 Vinh Nguyen. All rights reserved.
//

import ReactiveReSwift
import RxSwift

let itemMiddleware = Middleware<ItemState>().sideEffect { _, _, action in
    print("Received action:")
    }.map { _, action in
        print(action)
        return action
}

let itemStore = Store(
    reducer: itemReducer,
    observable: Variable(ItemState(currentItem: nil, cloud: nil)),
    middleware: itemMiddleware
)
