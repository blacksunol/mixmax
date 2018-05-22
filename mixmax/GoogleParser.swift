//
//  GoogleParser.swift
//  mixmax
//
//  Created by Apple on 4/30/18.
//  Copyright © 2018 Vinh Nguyen. All rights reserved.
//

import Foundation

struct GoogleParser : Parser {
    
    func parser(item: Item?, data: Data?) -> [GoogleItem] {
        
        let json = try?  JSON(data: data!)
        guard let jsonArray = json?["files"].array else {
            
            return []
        }
        
        var items = [GoogleItem]()

        for jsonItem in jsonArray {
            
            var newItem = GoogleItem()
            newItem.name = jsonItem["name"].string ?? ""
            newItem.parent = item
            
            let fileExtension = newItem.name?.components(separatedBy: ".").last ?? ""
            let mimeType = jsonItem["mimeType"].string
        
            if let mimeType = mimeType, mimeType == "application/vnd.google-apps.folder" {
                
                newItem.kind = .folder
            } else if self.playableFiles.contains(fileExtension) {
                
                newItem.kind =  .audio
            }
            

            let id = jsonItem["id"].string ?? ""
            newItem.id = id
            newItem.track.url = "https://www.googleapis.com/drive/v3/files/" + id + "?alt=media"
            items.append(newItem)
        }
        
        return items
    }
}
