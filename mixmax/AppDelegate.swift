//
//  AppDelegate.swift
//  mixmax
//
//  Created by Vinh Nguyen on 4/23/17.
//  Copyright © 2017 Vinh Nguyen. All rights reserved.
//

import UIKit
import GoogleSignIn
import SlideMenuControllerSwift
import AVFoundation


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        GoogleService.setup()
        DropboxService.setup()
        
        let menuStoryboard = UIStoryboard(name: "MenuViewController", bundle: nil)
        let menuViewController  = menuStoryboard.instantiateInitialViewController()

        let mainStoryboard = UIStoryboard(name: "ItemListViewController", bundle: nil)
        let mainViewController = mainStoryboard.instantiateInitialViewController()
    
        
        let slideMenuController = SlideMenuController(mainViewController: mainViewController!, rightMenuViewController: menuViewController!)
        
        self.window?.rootViewController = slideMenuController
        self.window?.makeKeyAndVisible()
        
       
       
        return true
    }

    func application(_ application: UIApplication,
                     open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        return GIDSignIn.sharedInstance().handle(url,
                                                 sourceApplication: sourceApplication,
                                                 annotation: annotation)
    }
    
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        
        DropboxService.handleRedirectURL(url: url)
        
        return GIDSignIn.sharedInstance().handle(url,
                                                 sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                 annotation: options[UIApplicationOpenURLOptionsKey.annotation])
    }
}

