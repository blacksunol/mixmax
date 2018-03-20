//
//  CloudService.swift
//  mixmax
//
//  Created by Vinh Nguyen on 3/19/18.
//  Copyright © 2018 Vinh Nguyen. All rights reserved.
//

import Foundation
import GoogleSignIn

enum Cloud {
    case google
    case dropbox
    case onedrive
}

class CloudService {
    
    func callDropbox(from item: Item, callFished: @escaping (_ items: [Item]) -> ()) {
        var items = [Item]()

        let kDropBoxToken = "http://localhost/#access_token="
        let dropBoxTokenString = UserDefaults.standard.value(forKey: kDropBoxToken) ?? ""
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let url = URL(string: "https://api.dropboxapi.com/2/files/list_folder")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.addValue("Bearer \(dropBoxTokenString)", forHTTPHeaderField: "Authorization")
        let jsonDictionary = ["path": item.path]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: jsonDictionary, options: .prettyPrinted)
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error  {
                print(error.localizedDescription)
            } else {
                DispatchQueue.main.async {
                    let json = try?  JSON(data: data!)
                    guard let jsonArray = json?["entries"].array else {
                        return
                    }
                    
                    for jsonItem in jsonArray {
                        let item = Item()
                        item.name = jsonItem["name"].string ?? ""
                        item.tag = jsonItem[".tag"].string ?? ""
                        item.path = jsonItem["path_lower"].string ?? ""
                        items.append(item)
                    }
                    
                    callFished(items)
                }
            }
        }
        
        task.resume()
        
    }
    
    func callDropboxLink(from item: Item, callFinished: @escaping (_ linkString: String) -> ()) {
        
        let kDropBoxToken = "http://localhost/#access_token="
        let dropBoxTokenString = UserDefaults.standard.value(forKey: kDropBoxToken) ?? ""
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let url = URL(string: "https://api.dropboxapi.com/2/files/get_temporary_link")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.addValue("Bearer \(dropBoxTokenString)", forHTTPHeaderField: "Authorization")
        let jsonDictionary = ["path": item.path]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: jsonDictionary, options: .prettyPrinted)
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error  {
                print(error.localizedDescription)
            } else {
                DispatchQueue.main.async {
                    let json = try?  JSON(data: data!)
                    if let link = json?["link"].string {
                        callFinished(link)
                    }
                }
            }
        }
        
        task.resume()
    }
    
    func callGoogle(callFished: @escaping (_ items: [Item]) -> ()){
        guard let accessToken = GIDSignIn.sharedInstance().currentUser.authentication.accessToken else {
            return
        }
        
        print("accessToken: \(accessToken)")
        var items = [Item]()
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let url = URL(string: "https://www.googleapis.com/drive/v3/files")
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error  {
                print(error.localizedDescription)
            } else {
                DispatchQueue.main.async {
                    let json = try?  JSON(data: data!)
                    guard let jsonArray = json?["files"].array else {
                        return
                    }
                    
                    for jsonItem in jsonArray {
                        let item = Item()
                        item.name = jsonItem["name"].string ?? ""
                        item.tag = jsonItem[".tag"].string ?? ""
                        item.path = jsonItem["path_lower"].string ?? ""
                        items.append(item)
                    }
                    
                    callFished(items)
                }
            }
        }
        
        task.resume()
    }
}
