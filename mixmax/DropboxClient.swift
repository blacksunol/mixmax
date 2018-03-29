//
//  DropboxClient.swift
//  mixmax
//
//  Created by Vinh Nguyen on 3/20/18.
//  Copyright © 2018 Vinh Nguyen. All rights reserved.
//
import Foundation
import PromiseKit
import SwiftyDropbox

class DropboxClient: Client {
   
    var url: String = "https://api.dropboxapi.com/2/files/list_folder"
    
    var method: String = "POST"
    
    var path: String = ""
    
    let kDropBoxToken = "http://localhost/#access_token="
    
    let accessToken = DropboxClientsManager.authorizedClient?.auth.client.accessToken ?? ""

    func callItems(from item: Item, callFished: @escaping ([Item]) -> ()) {
        callItems(from: item).then { items in
            callFished(items)
        }
    }
    
    private func callItems(from item: Item) -> Promise<[Item]> {
        return Promise { fulfill, _ in
            var items = [Item]()
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)
            
            let url = URL(string: self.url)
            var request = URLRequest(url: url!)
            request.httpMethod = method
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            let jsonDictionary = ["path": item.path]
            
            let jsonData = try? JSONSerialization.data(withJSONObject: jsonDictionary, options: .prettyPrinted)
            request.httpBody = jsonData
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let task = session.dataTask(with: request) { (data, response, error) in
                if let error = error  {
                    print(error.localizedDescription)
                } else {
                    let json = try? JSON(data: data!)
                    guard let jsonArray = json?["entries"].array else {
                        fulfill(items)
                        return
                    }
                    
                    for jsonItem in jsonArray {
                        let newItem = Item()
                        newItem.parent = item
                        newItem.name = jsonItem["name"].string ?? ""
                        newItem.kind = jsonItem[".tag"].string ?? ""
                        newItem.path = jsonItem["path_lower"].string ?? ""
                        items.append(newItem)
                    }
                    
                    let promises = items.map {  self.callPath(item: $0) }
                    
                    when(fulfilled: promises).then { (items ) in
                        fulfill(items)
                    }
                }
            }
            
            task.resume()
        }
    }
    
    private func callPath(item: Item) -> Promise<Item> {
        return Promise { fulfill, _ in
            
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)
            
            let url = URL(string: "https://api.dropboxapi.com/2/files/get_temporary_link")
            var request = URLRequest(url: url!)
            request.httpMethod = "POST"

            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            let jsonDictionary = ["path": item.path]
            
            let jsonData = try? JSONSerialization.data(withJSONObject: jsonDictionary, options: .prettyPrinted)
            request.httpBody = jsonData
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let task = session.dataTask(with: request) { (data, response, error) in
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
            
            task.resume()
        }

    }
}
