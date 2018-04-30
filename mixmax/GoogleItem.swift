//
//  GoogleItem.swift
//  mixmax
//
//  Created by Vinh Nguyen on 3/29/18.
//  Copyright © 2018 Vinh Nguyen. All rights reserved.
//

struct GoogleItem : Item {
    
    var name: String?
    
    var kind: Kind = .unknow
    
    var parent: Item?
    
    var track: Track = Track()
    
    var id = ""
    
    var cloud: Cloud = .google

}
