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

    func callItems(from item: Item?, callFinished: @escaping ([Item]) -> ()) {
        callItems(from: item).then { items in
            callFinished(items)
        }
    }
    
    private func callItems(from item: Item?) -> Promise<[Item]> {
        return Promise { fulfill, _ in
            
            var items = [DropboxItem]()
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)
            
            let url = URL(string: self.url)
            var request = URLRequest(url: url!)
            request.httpMethod = method
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
                    let json = try? JSON(data: data!)
                    guard let jsonArray = json?["entries"].array else {
                        fulfill(items)
                        return
                    }
                    
                    for jsonItem in jsonArray {
                        var newItem = DropboxItem()
                        newItem.parent = item
                        newItem.name = jsonItem["name"].string ?? ""
                        let tag = jsonItem[".tag"].string
                        if tag == "file" && newItem.name?.components(separatedBy: ".").last == "mp3" {
                            newItem.kind = .audio
                        } else if tag == "folder" {
                            newItem.kind = .folder
                        }
                        
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
    
    class func setup() {
        DropboxClientsManager.setupWithAppKey("yiyza1su258n3xz")
    }
    
    class func handleRedirectURL(url: URL) {
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
    
    class func authorize(controller: UIViewController) {
        DropboxClientsManager.authorizeFromController(UIApplication.shared, controller: controller, openURL: { (url: URL) -> Void in
            UIApplication.shared.openURL(url)
        })
    }
    
    class func signOut() {
        DropboxClientsManager.unlinkClients()
    }
}
