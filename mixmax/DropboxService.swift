//
//  DropboxService.swift
//  mixmax
//
//  Created by Apple on 4/23/18.
//  Copyright © 2018 Vinh Nguyen. All rights reserved.
//

import Foundation
import SwiftyDropbox

struct DropboxService : Service {
    
    let token = DropboxClientsManager.authorizedClient?.auth.client.accessToken ?? ""

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
        var dropboxItemList = DropboxItemList()
        dropboxItemList.token = token
        dropboxItemList.itemList(from: item) { items in
            callFinished(items)
        }
    }
}
