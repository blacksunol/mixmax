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

final class GoogleService : NSObject, Service, GIDSignInDelegate {
    
    let accessToken: BehaviorRelay<String> = BehaviorRelay(value: "")
    
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
        
        configure()
        
        let subscription = self.accessToken.asObservable().subscribe(onNext: { accessToken in
            
            var googleItemList = GoogleItemList()
            googleItemList.token = accessToken
            googleItemList.itemList(from: item) { items in
                callFinished(items)
            }
            
            print("accessToken = \(accessToken)")
            
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
}
