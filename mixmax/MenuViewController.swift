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
    let clouds: [CloudType] = [.dropbox, .google, .onedrive]
    var currentIndex: BehaviorRelay<CloudType> = BehaviorRelay(value: .dropbox)
}

extension MenuViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return clouds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cloudType = clouds[indexPath.row]
        let cell =  UITableViewCell()
        cell.textLabel?.text = cloudType.rawValue
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let slideMenuController = self.slideMenuController() {
            slideMenuController.closeRight()
            let cloudType = clouds[indexPath.row]
            currentIndex.accept(cloudType)
        }
    }
}


