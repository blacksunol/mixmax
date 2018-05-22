//
//  ItemList.swift
//  mixmax
//
//  Created by Apple on 4/23/18.
//  Copyright © 2018 Vinh Nguyen. All rights reserved.
//

protocol ItemList {
    
    func itemList(from item: Item? , callFinished: @escaping (_ items: [Item]) -> ())
}
