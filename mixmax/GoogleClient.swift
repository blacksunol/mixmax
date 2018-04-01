//
//  GoogleClient.swift
//  mixmax
//
//  Created by Vinh Nguyen on 3/20/18.
//  Copyright © 2018 Vinh Nguyen. All rights reserved.
//  signIn.scopes = ["https://www.googleapis.com/auth/plus.login","https://www.googleapis.com/auth/plus.me"]
//GIDSignIn.sharedInstance().scopes.append("https://www.googleapis.com/auth/drive.file")


import Foundation
import GoogleSignIn
import RxCocoa

class GoogleClient : NSObject, Client, GIDSignInDelegate {
    
    private let accessToken: BehaviorRelay<String> = BehaviorRelay(value: "")
    
    var url: String = "https://www.googleapis.com/drive/v3/files"
    var method: String = "GET"
    var path: String = ""
    
    func callItems(from item: Item?, callFished:  @escaping (_ items: [Item]) -> ()) {
        
        var folderId = "root"
        if let googleItem = item as? GoogleItem {
            folderId = googleItem.id
        }
        
        configure()
        
        let subscription = self.accessToken.asObservable().subscribe(onNext: { accessToken in
            print("accessToken = \(accessToken)")
            var items = [Item]()
            
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)
            let url = URL(string: self.url + "?q='" + folderId + "'%20in%20parents")
            var request = URLRequest(url: url!)
            request.httpMethod = self.method
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            let task = session.dataTask(with: request) { (data, response, error) in
                if let error = error  {
                    print(error.localizedDescription)
                } else {
                    DispatchQueue.main.async {
                        let json = try?  JSON(data: data!)
                        guard let jsonArray = json?["files"].array else {
                            callFished(items)
                            return
                        }
                        
                        for jsonItem in jsonArray {
                            let newItem = GoogleItem()
                            newItem.name = jsonItem["name"].string ?? ""
                            newItem.parent = item
                            let mimeType = jsonItem["mimeType"].string
                            if let mimeType = mimeType, mimeType.contains("audio") {
                                newItem.kind =  .audio
                            } else if mimeType == "application/vnd.google-apps.folder" {
                                newItem.kind = .folder
                            }
                            newItem.track.token = accessToken
                            let id = jsonItem["id"].string ?? ""
                            newItem.id = id
                            newItem.track.url = "https://www.googleapis.com/drive/v3/files/" + id + "?alt=media"
                            items.append(newItem)
                        }
                        
                        callFished(items)
                        
                    }
                }
            }
            
            task.resume()
            
        }, onError: { (error) in
            print("errror")
        }, onCompleted: {
            print("complete")
        }, onDisposed: {
            print("dispose")
        })
        subscription.dispose()
        
    }
    
    private func configure() {
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().signInSilently()
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            print(error.localizedDescription)
            
        } else {
            accessToken.accept(GIDSignIn.sharedInstance().currentUser.authentication.accessToken)
        }   
    }
    
    class func setup() {
        GIDSignIn.sharedInstance().clientID = "1081018989060-95jkittnpf1oi28hkonjsoiipol1iajj.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().scopes = ["https://www.googleapis.com/auth/drive.readonly"]
        GIDSignIn.sharedInstance().signInSilently()
    }
}
