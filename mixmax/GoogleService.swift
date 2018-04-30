//
//  GoogleService.swift
//  mixmax
//
//  Created by Vinh Nguyen on 3/20/18.
//  Copyright © 2018 Vinh Nguyen. All rights reserved.
//  signIn.scopes = ["https://www.googleapis.com/auth/plus.login","https://www.googleapis.com/auth/plus.me"]
//GIDSignIn.sharedInstance().scopes.append("https://www.googleapis.com/auth/drive.file")


import Foundation
import GoogleSignIn
import RxCocoa

final class GoogleService : NSObject, Service, Request, GIDSignInDelegate {
    
    var request: URLRequest?
    
    
    let accessToken: BehaviorRelay<String> = BehaviorRelay(value: "")
    
    var url: String = "https://www.googleapis.com/drive/v3/files"
    var method = Method.get
    var path: String = ""

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {

        if let error = error {
            
            print(error.localizedDescription)
        } else {

            accessToken.accept(GIDSignIn.sharedInstance().currentUser.authentication.accessToken)
            clientStore.dispatch(LoginAction())
        }   
    }
    
    static var isAuthorize: Bool {
        
        get {
            
            return GIDSignIn.sharedInstance().hasAuthInKeychain() ? true : false
        }
    }

    class func setup() {
        
        GIDSignIn.sharedInstance().clientID = "779028964365-89k4hkidvgpsr4l3m4vkuknkmr5m6mcf.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().scopes = ["https://www.googleapis.com/auth/drive.readonly"]
        GIDSignIn.sharedInstance().signInSilently()
    }
    
    class func authorize(controller: UIViewController) {

        GIDSignIn.sharedInstance().delegate = controller as! GIDSignInDelegate
        GIDSignIn.sharedInstance().uiDelegate = controller as! GIDSignInUIDelegate
        GIDSignIn.sharedInstance().signIn()
    }
    
    class func signOut() {
        
        GIDSignIn.sharedInstance().signOut()
    }
}

extension GoogleService : ItemList {
    
    func itemList(from item: Item?, callFinished: @escaping ([Item]) -> ()) {
        callItems(from: item) { items in
            callFinished(items)
        }
    }
    
    private func callItems(from item: Item?, callFinished:  @escaping (_ items: [Item]) -> ()) {
        
        var folderId = "root"
        if let googleItem = item as? GoogleItem {
            folderId = googleItem.id
        }
        
        configure()
        
        let subscription = self.accessToken.asObservable().subscribe(onNext: { accessToken in
            
            print("accessToken = \(accessToken)")
            
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)
            let url = URL(string: self.url + "?q='" + folderId + "'%20in%20parents")
            var request = URLRequest(url: url!)
            request.httpMethod = self.method.rawValue
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            let task = session.dataTask(with: request) { (data, response, error) in
                
                if let error = error  {
                    
                    print(error.localizedDescription)
                } else {
                    
                    DispatchQueue.main.async {
                        
                        let googleParser = GoogleParser()
                        let items = googleParser.parser(item: item, data: data).map { self.grantToken(item: $0, token: accessToken) }
                        
                        callFinished(items)
                        
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
    
    private func grantToken(item: Item, token: String) -> Item {
        
        var item = item
        item.track.token = token
        return item
    }
}
