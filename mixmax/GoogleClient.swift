//
//  GoogleClient.swift
//  mixmax
//
//  Created by Vinh Nguyen on 3/20/18.
//  Copyright © 2018 Vinh Nguyen. All rights reserved.
// https://stackoverflow.com/questions/46237573/swift-google-sign-in

import Foundation
import GoogleSignIn
import GoogleAPIClientForREST


class GoogleClient: NSObject, Client, GIDSignInDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        print("google logined")
        
    }
    var url: String = "https://www.googleapis.com/drive/v3/files"
    var method: String = "GET"
    var path: String = ""
    
    func callItems(from item: Item, callFished: @escaping (_ items: [Item]) -> ()) {
        
        configure()
        guard let accessToken = GIDSignIn.sharedInstance().currentUser.authentication.accessToken else {
            return
        }
        
        var items = [Item]()

        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)

        let url = URL(string: self.url)
        var request = URLRequest(url: url!)
        request.httpMethod = method
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
    
    private func configure() {
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().scopes = [kGTLRAuthScopeDriveReadonly]
        GIDSignIn.sharedInstance().signInSilently()

    }

}

