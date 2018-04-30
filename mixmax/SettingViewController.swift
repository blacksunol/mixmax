//
//  SettingViewController.swift
//  mixmax
//
//  Created by Vinh Nguyen on 3/20/18.
//  Copyright © 2018 Vinh Nguyen. All rights reserved.
//

import UIKit
import GoogleSignIn
import ReactiveReSwift
import RxSwift

class SettingViewController: UIViewController {
    
    @IBOutlet weak var settingTableView: UITableView!
    fileprivate let settingViewModel = SettingViewModel(clouds:  [.google, .dropbox])
    let disposeBag = SubscriptionReferenceBag()
    
    func showAlert(cloud: Cloud) {
        
        let alert = UIAlertController(
            title: "Sign out",
            message: "Sign out \(cloud.rawValue)",
            preferredStyle: UIAlertControllerStyle.alert
        )
        
        let ok = UIAlertAction(
            title: "OK",
            style: .default
            ) { (action:UIAlertAction!) in
                if cloud == .dropbox { DropboxService.signOut() }
                if cloud == .google { GoogleService.signOut() }
                menuStore.dispatch(MenuRemoveCloudAction(cloud: cloud))
                clientStore.dispatch(LoginAction())
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)        
        alert.addAction(ok)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        disposeBag += clientStore.observable.asObservable().skip(1).subscribe { [weak self] clientState in
            
            guard let weakSelf = self else { return }
            weakSelf.settingTableView.reloadData()
            weakSelf.navigationController?.popToRootViewController(animated: true)
        }
        
    }
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
         let cellViewModel = settingViewModel.cellViewModels?[indexPath.row]
        
        if indexPath.row == 0 {
            
            let isActive = cellViewModel?.isActive ?? false
            if isActive {
                
                showAlert(cloud: .google)
                return
            }
            
            GoogleService.authorize(controller: self)
        } else {
            
            let isActive = cellViewModel?.isActive ?? false
            if isActive {
                
                showAlert(cloud: .dropbox)
                return
            }
            
            DropboxService.authorize(controller: self)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 100  
    }
}

extension SettingViewController: GIDSignInUIDelegate, GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if let error = error {
            
            print(error.localizedDescription)
        } else {
            
            clientStore.dispatch(LoginAction())
            menuStore.dispatch(MenuAddCloudAction(cloud: .google))
            menuStore.dispatch(SelectedCloudAction(cloud: .google))
        }
    }
}
