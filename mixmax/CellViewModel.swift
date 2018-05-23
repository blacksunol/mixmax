//
//  CellViewModel.swift
//  mixmax
//
//  Created by Apple on 5/2/18.
//  Copyright © 2018 Vinh Nguyen. All rights reserved.
//

import UIKit

protocol Reusable: class {
    static var reuseIdentifier: String { get }
}

extension Reusable {
    static var reuseIdentifier: String { return String(describing: self) }
}

protocol DisplayCell {
    
    func display2<T: CellViewModel>(cellViewModel viewModel: T)
}

protocol CellViewModel {
    
    
}

extension UITableViewCell  {
    
//    public func dequeueReusableCell2<T: UITableViewCell>(withClass name: T.Type, for indexPath: IndexPath) -> T {
//        
//        let cell = dequeueReusableCell(withClass: name, for: indexPath)
//        return cell
//    }
    
    static var reuseIdentifier2 : String  { return "MenuTableViewCell" }
    
    static func dequeueReusableCell2<T: UITableViewCell> (tableView: UITableView) -> T? where T: Reusable {
        
        return tableView.dequeueReusableCell(withIdentifier: String(describing: T.reuseIdentifier)) as? T
    }
    

}
