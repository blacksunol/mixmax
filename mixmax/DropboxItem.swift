//
//  DropboxItem.swift
//  mixmax
//
//  Created by Vinh Nguyen on 3/29/18.
//  Copyright © 2018 Vinh Nguyen. All rights reserved.
//

struct DropboxItem: Item {
    
    var name: String?
    
    var kind: Kind = .unknow
    
    var parent: Item?
    
    var track: Track = Track()
    
    var path = ""
}
