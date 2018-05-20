//
//  CloudClient.swift
//  mixmax
//
//  Created by Vinh Nguyen on 3/19/18.
//  Copyright © 2018 Vinh Nguyen. All rights reserved.
//

import Foundation
import RxSwift

enum Cloud: String, EnumCollection {
    
    case google = "google"
    case dropbox = "dropbox"
    case onedrive = "onedrive"
    case none
}

class CloudClient {
    
    let downloader = Downloader.shared
    
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
            
            let localPath = LocalPath()
            let fetchedItems = localPath.fetchLocalPath(items: items)
            
            callFished(fetchedItems)
        }
    }
    
    func download(item: Item?) {
        
        guard let item = item else { return }
        downloader.start(urlString: item.track.url, fileName: item.name, fileId: item.localPath, token: item.track.token)
    }
    
    func removeDownload(item: Item?, completed: (String) -> () ) {
        
        downloader.remove(item: item) { url in
            completed(url)
        }
    }
}
