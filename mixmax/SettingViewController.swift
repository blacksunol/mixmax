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
    
    func showAlert(title : String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.alert
        )
        let ok = UIAlertAction(
            title: "OK",
            style: UIAlertActionStyle.default,
            handler: nil
        )
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        disposeBag += clientStore.observable.asObservable().skip(1).subscribe { [weak self] clientState in
            
            print("Client state")
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
                
                let title = cellViewModel?.title ?? ""
                showAlert(title: title, message: "Sign out")
                GoogleClient.signOut()
                menuStore.dispatch(MenuRemoveCloudAction(cloud: .google))
                clientStore.dispatch(LoginAction())
                return
            }
            
            GoogleClient.authorize(controller: self)
        } else {
            
            let isActive = cellViewModel?.isActive ?? false
            if isActive {
                
                let title = cellViewModel?.title ?? ""
                showAlert(title: title, message: "Sign out")
                DropboxClient.signOut()
                menuStore.dispatch(MenuRemoveCloudAction(cloud: .dropbox))
                clientStore.dispatch(LoginAction())
                return
            }
            
            DropboxClient.authorize(controller: self)
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
