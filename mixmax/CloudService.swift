//
//  CloudService.swift
//  mixmax
//
//  Created by Vinh Nguyen on 3/19/18.
//  Copyright © 2018 Vinh Nguyen. All rights reserved.
//

import Foundation

enum CloudType {
    case google
    case dropbox
    case onedrive
}

class CloudService {
    
    func callItems(from item: Item, cloudType: CloudType, callFished: @escaping (_ items: [Item]) -> ()) {
        
        var client: Client?

        switch cloudType {
        case .dropbox:
            client = DropboxClient()
        case .google:
            client = GoogleClient()
        default:
            break
        }
        
        client?.callItems(from: item) { (items) in
            callFished(items)
        }
    }
}
