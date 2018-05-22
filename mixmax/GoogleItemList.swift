//
//  GoogleItemList.swift
//  mixmax
//
//  Created by Apple on 5/2/18.
//  Copyright © 2018 Vinh Nguyen. All rights reserved.
//


struct GoogleItemList: ItemList {
    
    var token = ""
    
    let url: String = "https://www.googleapis.com/drive/v3/files"
    
    func itemList(from item: Item?, callFinished: @escaping ([Item]) -> ()) {
        
        var folderId = "root"
        if let googleItem = item as? GoogleItem {
            folderId = googleItem.id
        }
        
        let urlStr = self.url + "?q='" + folderId + "'%20in%20parents"
        let request2 = Request(url: urlStr, method: .get, token: token)
        request2.requestSession { (data, response, error) in
            
            if let error = error  {
                
                print(error.localizedDescription)
            } else {
                
                let googleParser = GoogleParser()
                let items = googleParser.parser(item: item, data: data).map { self.grantToken(item: $0, token: self.token) }
                callFinished(items)
            }
        }
    }
    
    private func grantToken(item: Item, token: String) -> Item {
        
        var item = item
        item.track.token = token
        return item
    }
}
