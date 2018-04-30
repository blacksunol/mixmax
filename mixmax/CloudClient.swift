//
//  CloudClient.swift
//  mixmax
//
//  Created by Vinh Nguyen on 3/19/18.
//  Copyright © 2018 Vinh Nguyen. All rights reserved.
//

import Foundation

enum Cloud: String, EnumCollection {
    
    case google = "google"
    case dropbox = "dropbox"
    case onedrive = "onedrive"
    case none
}

class CloudClient {
    
    func callItems(from item: Item?, cloud: Cloud , callFished: @escaping (_ items: [Item]) -> ()) {
        
        var itemList: ItemList?

        switch cloud {
        case .dropbox:
            itemList = DropboxService()
        case .google:
            itemList = GoogleService()
        default:
            callFished([])
        }
        
        itemList?.itemList(from: item) { (items) in
            
            callFished(items)
        }
    }
}
