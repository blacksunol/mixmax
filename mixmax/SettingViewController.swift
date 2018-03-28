//
//  SettingViewController.swift
//  mixmax
//
//  Created by Vinh Nguyen on 3/20/18.
//  Copyright © 2018 Vinh Nguyen. All rights reserved.
//

import UIKit
import SwiftyDropbox

class SettingViewController: UIViewController {
    
    
}

extension SettingViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  UITableViewCell()
        cell.textLabel?.text = indexPath.row == 0 ? "Google" : "Dropbox"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            let storyboard = UIStoryboard(name: "GoogleLoginViewController", bundle: nil)
            if let vc = storyboard.instantiateViewController(withIdentifier :"GoogleLoginViewController") as? GoogleLoginViewController {
                present(vc, animated: true)
            }
        } else {
            DropboxClientsManager.authorizeFromController(UIApplication.shared, controller: self, openURL: { (url: URL) -> Void in
                UIApplication.shared.openURL(url)
            })
        }
    }
}

