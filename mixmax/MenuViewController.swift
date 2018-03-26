//
//  MenuViewController.swift
//  mixmax
//
//  Created by Vinh Nguyen on 3/20/18.
//  Copyright © 2018 Vinh Nguyen. All rights reserved.
//

import UIKit
import RxCocoa

class MenuViewController: UIViewController {
    
    fileprivate let sections = ["cloud", "feature"]
    let features = ["Setting", "Help"]
    let currentFeature: BehaviorRelay<String> = BehaviorRelay(value: "")
    let clouds: [CloudType] = [.dropbox, .google, .onedrive]
    var currentCloud: BehaviorRelay<CloudType> = BehaviorRelay(value: .none)
}

extension MenuViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section] == "cloud" ? clouds.count : features.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if sections[indexPath.section] == "cloud" {
            let cloudType = clouds[indexPath.row]
            let cell =  UITableViewCell()
            cell.textLabel?.text = cloudType.rawValue
            return cell
        } else {
            let feature = features[indexPath.row]
            let cell =  UITableViewCell()
            cell.textLabel?.text = feature
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
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


