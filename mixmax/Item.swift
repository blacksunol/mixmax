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

protocol Item {
    var name: String? { get set }
    var kind: Kind { get set }
    var parent: Item? { get set }
    var track: Track { get set }
}

extension Item {
    var isPlayable: Bool {
        get { return kind == .audio }
    }
    
    var kind: Kind {
        get { return  .unknow }
    }
}
