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
    var cloud: Cloud { get }
    var localPath: String { get }
}

extension Item {
    
    var isPlayable: Bool {
        get { return kind == .audio }
    }
    
    var kind: Kind {
        get { return  .unknow }
    }
}

extension Item {

    var localPath: String {

        var item: Item? = self
        
        var path = ""

        while item?.name != nil {
            
            path = (item?.name)! + "/" + path
            item = item?.parent
        }
        
        path = cloud.rawValue + "/" + path
        path.removeLast()
        
        return path
    }
}
