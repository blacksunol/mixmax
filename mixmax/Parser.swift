//
//  Parser.swift
//  mixmax
//
//  Created by Vinh Nguyen on 4/13/18.
//  Copyright © 2018 Vinh Nguyen. All rights reserved.
//

import Foundation

protocol Parser {
    
    var playableFiles: [String] { get }
}

extension Parser {
    
    var playableFiles: [String] {
        
        return ["mp3", "mp4", "wav", "wma", "m4v", "avi", "mpeg", "3gp", "m4a"]
    }
}

struct Parser2<T: Item> {
    
    func parse() -> [T] {
        return []
    }
}
