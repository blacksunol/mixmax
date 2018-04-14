//
//  MenuViewController.swift
//  mixmax
//
//  Created by Vinh Nguyen on 3/20/18.
//  Copyright © 2018 Vinh Nguyen. All rights reserved.
//

import UIKit
import RxCocoa
import ReactiveReSwift
import RxSwift

class MenuViewController: UIViewController {
    
    @IBOutlet weak var menuTableView: UITableView!
    fileprivate let sections = ["cloud", "feature"]
    let features = ["Setting"]
    let currentFeature: BehaviorRelay<String> = BehaviorRelay(value: "")
    fileprivate var settingViewModel = SettingViewModel(clouds:  [])
    
    
    let disposeBag = SubscriptionReferenceBag()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let clouds = CloudType.allValues.filter {
            switch  $0 {
            case .dropbox:
                return DropboxClient.isAuthorize
            case .google:
                return GoogleClient.isAuthorize
            default:
                return false
            }
        }
        
        menuStore.dispatch(InitCloudsAction(clouds: clouds))
        
        disposeBag += menuStore.observable.subscribe { [weak self] in
            itemStore.dispatch(ItemAction(currentItem: nil, cloud: $0.selectedCloud))
            guard let weakSelf = self else { return }
            weakSelf.settingViewModel = SettingViewModel(clouds: $0.clouds)
            weakSelf.menuTableView.reloadData()
        }
        
    }
}

extension MenuViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let viewModelCount = settingViewModel.cellViewModels?.count ?? 0
        return sections[section] == "cloud" ? viewModelCount : features.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if sections[indexPath.section] == "cloud" {
            guard let cell = MenuTableViewCell.dequeueReusableCell(tableView: tableView) else { return UITableViewCell() }
            guard let cellViewModel = settingViewModel.cellViewModels?[indexPath.row]
            else { return UITableViewCell() }
            cell.display(settingCellViewModel: cellViewModel)
            return cell
        } else {
            guard let cell = MenuTableViewCell.dequeueReusableCell(tableView: tableView) else { return UITableViewCell() }
            let cellViewModel = SettingCellViewModel(title: "Setting", imageName: "setting", isActive: true)
            cell.display(settingCellViewModel: cellViewModel)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let vc = self.slideMenuController()?.mainViewController as? UINavigationController {
             vc.popToRootViewController(animated: false)
        }
        
        if sections[indexPath.section] == "cloud" {
            
            if let slideMenuController = self.slideMenuController() {
                slideMenuController.closeRight()
                let cloudType = settingViewModel.clouds[indexPath.row]
                menuStore.dispatch(SelectedCloudAction(cloud: cloudType))
            }
        } else {
            
            if let slideMenuController = self.slideMenuController() {
                slideMenuController.closeRight()
                let feature = features[indexPath.row]
                currentFeature.accept(feature)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

