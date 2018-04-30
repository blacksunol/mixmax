//
//  DropboxService.swift
//  mixmax
//
//  Created by Apple on 4/23/18.
//  Copyright © 2018 Vinh Nguyen. All rights reserved.
//

import Foundation
import PromiseKit
import SwiftyDropbox

struct DropboxService : Service, Request {
    
    var url: String = "https://api.dropboxapi.com/2/files/list_folder"
    
    var method: Method = .post
    
    var path: String = ""
    
    var request: URLRequest?
    
    let kDropBoxToken = "http://localhost/#access_token="
    
    let accessToken = DropboxClientsManager.authorizedClient?.auth.client.accessToken ?? ""
    
    static func setup() {
        
        DropboxClientsManager.setupWithAppKey("yiyza1su258n3xz")
    }
    
    static func handleRedirectURL(url: URL) {
        
        if let authResult = DropboxClientsManager.handleRedirectURL(url) {
            switch authResult {
            case .success:
                print("Success! User is logged into Dropbox.")
                clientStore.dispatch(LoginAction())
                menuStore.dispatch(MenuAddCloudAction(cloud: .dropbox))
                menuStore.dispatch(SelectedCloudAction(cloud: .dropbox))
            case .cancel:
                print("Authorization flow was manually canceled by user!")
            case .error(_, let description):
                print("Error: \(description)")
            }
        }
    }
    
    static var isAuthorize: Bool {
        
        get {
            
            if let _ = DropboxClientsManager.authorizedClient {
                
                return true
            } else {
                
                return false
            }
        }
    }
    
    static func authorize(controller: UIViewController) {
        
        DropboxClientsManager.authorizeFromController(UIApplication.shared, controller: controller, openURL: { (url: URL) -> Void in
            UIApplication.shared.openURL(url)
        })
    }
    
    static func signOut() {
        
        DropboxClientsManager.unlinkClients()
    }
}

extension DropboxService : ItemList {
    
    func itemList(from item: Item?, callFinished: @escaping ([Item]) -> ()) {
        
        callItems(from: item).then { items in
            
            callFinished(items)
        }
    }
    
    private func callItems(from item: Item?) -> Promise<[Item]> {
        return Promise { fulfill, _ in
            
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)
            
            let url = URL(string: self.url)
            var request = URLRequest(url: url!)
            request.httpMethod = method.rawValue
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            var jsonDictionary = ["path": ""]
            if let dropboxItem = item as? DropboxItem {
                jsonDictionary = ["path": dropboxItem.path]
            }
            let jsonData = try? JSONSerialization.data(withJSONObject: jsonDictionary, options: .prettyPrinted)
            request.httpBody = jsonData
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let task = session.dataTask(with: request) { (data, response, error) in
                if let error = error  {
                    
                    print(error.localizedDescription)
                } else {
                    
                    let dropboxParser = DropboxParser()
                    let items = dropboxParser.parser(item: item, data: data)
                    
                    
                    let promises = items.map {  self.callPath(item: $0) }
                    
                    when(fulfilled: promises).then { (items ) in
                        
                        fulfill(items)
                    }
                }
            }
            
            task.resume()
        }
    }
    
    private func callPath(item: DropboxItem) -> Promise<DropboxItem> {
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
            
            task.resume()
        }
    }
}
