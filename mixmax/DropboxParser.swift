//
//  DropboxParser.swift
//  mixmax
//
//  Created by Apple on 4/21/18.
//  Copyright © 2018 Vinh Nguyen. All rights reserved.
//

import Foundation

struct DropboxParser: Parser {
    
    func parser(item: Item?, data: Data?) -> [DropboxItem] {
        
        let json = try? JSON(data: data!)
        guard let jsonArray = json?["entries"].array else {
            return []
        }
        
        var items = [DropboxItem]()
        
        for jsonItem in jsonArray {
            
            var newItem = DropboxItem()
            newItem.parent = item
            newItem.name = jsonItem["name"].string ?? ""
            let tag = jsonItem[".tag"].string
            let fileExtension = newItem.name?.components(separatedBy: ".").last ?? ""
            if tag == "file" && self.playableFiles.contains(fileExtension) {
                newItem.kind = .audio
            } else if tag == "folder" {
                newItem.kind = .folder
            }
            
            newItem.path = jsonItem["path_lower"].string ?? ""
            items.append(newItem)
        }
        
        return items
    }
}
