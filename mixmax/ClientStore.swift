//
//  ClientStore.swift
//  mixmax
//
//  Created by Vinh Nguyen on 4/8/18.
//  Copyright © 2018 Vinh Nguyen. All rights reserved.
//

import ReactiveReSwift
import RxSwift

let clientMiddleware = Middleware<ClientState>().sideEffect { _, _, action in
    print("Received action:")
    }.map { _, action in
        print(action)
        return action
}

let clientStore = Store(
    reducer: clientReducer,
    observable: Variable(ClientState()),
    middleware: clientMiddleware
)
