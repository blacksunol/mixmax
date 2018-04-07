//
//  Client.swift
//  mixmax
//
//  Created by Vinh Nguyen on 3/23/18.
//  Copyright © 2018 Vinh Nguyen. All rights reserved.
//

import Foundation

protocol Client {
    
    var url: String { get set }
    var method: String { get set }
    var path: String { get set}
    
    func callItems(from item: Item?, callFinished: @escaping (_ items: [Item]) -> ())
}
