//
//  Parser.swift
//  mixmax
//
//  Created by Vinh Nguyen on 4/13/18.
//  Copyright © 2018 Vinh Nguyen. All rights reserved.
//

import Foundation

protocol Parser {
    var json: String { get }
    func parse() -> [Item]
}

struct Parser2<T: Item> {
    
    func parse() -> [T] {
        return []
    }
}
