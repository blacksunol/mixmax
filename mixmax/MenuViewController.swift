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
    
    fileprivate let sections = ["cloud", "feature"]
    let features = ["Setting", "Help"]
    let currentFeature: BehaviorRelay<String> = BehaviorRelay(value: "")
    let clouds: [CloudType] = [.dropbox, .google, .onedrive]
    var currentCloud: BehaviorRelay<CloudType> = BehaviorRelay(value: .none)
    
    let disposeBag = SubscriptionReferenceBag()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let clouds = mainStore.observable.map { $0.clouds}
//
//
//        disposeBag += mainStore.observable.subscribe { [weak self] menuListState in
//            print("#menuListState: \(menuListState)")
//
//        }
        
    }
}

extension MenuViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section] == "cloud" ? clouds.count : features.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = MenuTableViewCell.dequeueReusableCell(tableView: tableView) else { return UITableViewCell() }
        
        if sections[indexPath.section] == "cloud" {
            let cloudType = clouds[indexPath.row]
            cell.textLabel?.text = cloudType.rawValue
            cell.imageView?.image = UIImage(named: "google")
            return cell
        } else {
            let feature = features[indexPath.row]
            cell.textLabel?.text = feature
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        let action = MenuAddCloudAction(cloud: .dropbox)

//        mainStore.dispatch(action)

        if let vc = self.slideMenuController()?.mainViewController as? UINavigationController {
             vc.popToRootViewController(animated: true)
        }
        
        if sections[indexPath.section] == "cloud" {
            if let slideMenuController = self.slideMenuController() {
                slideMenuController.closeRight()
                let cloudType = clouds[indexPath.row]
                currentCloud.accept(cloudType)
            }
        } else {
            if let slideMenuController = self.slideMenuController() {
                slideMenuController.closeRight()
                let feature = features[indexPath.row]
                currentFeature.accept(feature)
            }
        }
    }
}


