//
//  DropboxItemList.swift
//  mixmax
//
//  Created by Apple on 4/30/18.
//  Copyright © 2018 Vinh Nguyen. All rights reserved.
//

import Foundation
import PromiseKit

struct DropboxItemList : ItemList {
    
    enum Path: String {
        
        case listFolder = "list_folder"
        case getTemporaryLink = "get_temporary_link"
    }
    
    let url: String = "https://api.dropboxapi.com/2/files/"
    
    var token = ""
    
    func itemList(from item: Item?, callFinished: @escaping ([Item]) -> ()) {
        
        callItems(from: item).then { items in
            
            callFinished(items)
        }
    }
    
    private func callItems(from item: Item?) -> Promise<[Item]> {
        
        return Promise { fulfill, _ in
            
            var request = Request(url: url + Path.listFolder.rawValue, method: .post, token: token)
            
            let dropboxItem = item as? DropboxItem
            let path = dropboxItem?.path ?? ""
            request.setParamenter(path: path)
            
            request.requestSession { (data, response, error) in
                
                if let error = error  {
                    
                    print(error.localizedDescription)
                } else {
                    
                    let dropboxParser = DropboxParser()
                    let items = dropboxParser.parser(item: item, data: data)
                    
                    let promises = items.map {  self.callPath(item: $0) }
                    
                    when(fulfilled: promises).then { items in
                        
                        fulfill(items)
                    }
                }
            }
        }
    }
    
    private func callPath(item: DropboxItem) -> Promise<DropboxItem> {
        
        return Promise { fulfill, _ in
            
            var request = Request(url: url + Path.getTemporaryLink.rawValue, method: .post, token: token)
            request.setParamenter(path: item.path)
            request.requestSession { (data, response, error) in
                
                var item = item
                if let error = error {
                    
                    print(error.localizedDescription)
                } else {
                    
                    let json = try? JSON(data: data!)
                    if let linkUrl = json?["link"].string {
                        item.track.url = linkUrl
                    }
                }
                
                fulfill(item)
            }
        }
    }
}
