//
//  UIWindow+Extension.swift
//  mixmax
//
//  Created by nhatlee on 4/3/18.
//  Copyright © 2018 Vinh Nguyen. All rights reserved.
//

//import Foundation
import UIKit
extension UIApplication {
    static func topViewController() -> UIViewController? {
        var top = UIApplication.shared.keyWindow?.rootViewController
        while true {
            if let presented = top?.presentedViewController {
                top = presented
            } else if let nav = top as? UINavigationController {
                top = nav.visibleViewController
            } else if let tab = top as? UITabBarController {
                top = tab.selectedViewController
            } else {
                break
            }
        }
        return top
    }
}
