//
//  SettingViewController.swift
//  mixmax
//
//  Created by Vinh Nguyen on 3/20/18.
//  Copyright © 2018 Vinh Nguyen. All rights reserved.
//

import UIKit
import SwiftyDropbox
import GoogleSignIn

class SettingViewController: UIViewController {
    
    fileprivate let settingViewModel = SettingViewModel(clouds:  [.google, .dropbox])
}

extension SettingViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingViewModel.cellViewModels?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = SettingTableViewCell.dequeueReusableCell(tableView: tableView),
            let cellViewModel = settingViewModel.cellViewModels?[indexPath.row]
            else { return UITableViewCell() }
        
        cell.display(settingCellViewModel: cellViewModel)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            GoogleClient.authorize(controller: self)
        } else {
            DropboxClient.authorize(controller: self)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100  
    }
}

extension SettingViewController: GIDSignInUIDelegate, GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
    }
}
