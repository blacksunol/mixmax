//
//  Item.swift
//  mixmax
//
//  Created by Vinh Nguyen on 4/26/17.
//  Copyright © 2017 Vinh Nguyen. All rights reserved.
//

enum Kind {
    case folder
    case audio
    case unknow
}

class Item {
    var name = ""
    var kind: Kind = .unknow
    var track = Track()
    var isPlayable = true
    var parent: Item?
}
