//
//  MenuListViewModel.swift
//  mixmax
//
//  Created by Vinh Nguyen on 4/3/18.
//  Copyright © 2018 Vinh Nguyen. All rights reserved.
//

import Foundation

struct MenuListViewModel {
    
    let clouds: [Cloud] = [.dropbox, .google, .onedrive]

    let items: [MenuCellViewModel]
    var count: Int { return clouds.count }
    
    let row: Int?
//    var selectedCell: MenuCellViewModel? {
//
//        guard let selectedCell = selectedCell else { return nil }
//        return items[selectedCell]
//    }
}
