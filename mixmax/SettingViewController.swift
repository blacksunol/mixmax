//
//  SettingViewController.swift
//  mixmax
//
//  Created by Vinh Nguyen on 3/20/18.
//  Copyright © 2018 Vinh Nguyen. All rights reserved.
//

import UIKit

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
            let storyboard = UIStoryboard(name: "DropBoxLoginViewController", bundle: nil)
            if let vc = storyboard.instantiateViewController(withIdentifier :"DropBoxLoginViewController") as? DropBoxLoginViewController {
                present(vc, animated: true)
            }
        }
        
    }
}

