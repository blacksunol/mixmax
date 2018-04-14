//
//  CloudService.swift
//  mixmax
//
//  Created by Vinh Nguyen on 3/19/18.
//  Copyright © 2018 Vinh Nguyen. All rights reserved.
//

import Foundation

enum CloudType: String, EnumCollection {
    case google = "google"
    case dropbox = "dropbox"
    case onedrive = "onedrive"
    case none
}

class CloudService {
    
    func callItems(from item: Item?, cloud: CloudType , callFished: @escaping (_ items: [Item]) -> ()) {
        
        var client: Client?

        switch cloud {
        case .dropbox:
            client = DropboxClient()
        case .google:
            client = GoogleClient()
        default:
            callFished([])
        }
        
        client?.callItems(from: item) { (items) in
            callFished(items)
        }
    }
}
