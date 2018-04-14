//
//  ItemAction.swift
//  mixmax
//
//  Created by Vinh Nguyen on 4/13/18.
//  Copyright © 2018 Vinh Nguyen. All rights reserved.
//

import ReactiveReSwift

struct ItemAction: Action {
    
    let currentItem: Item?
    let cloud: CloudType
}
