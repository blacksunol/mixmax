//
//  MenuListActions.swift
//  mixmax
//
//  Created by Vinh Nguyen on 4/5/18.
//  Copyright © 2018 Vinh Nguyen. All rights reserved.
//

import Foundation
import ReactiveReSwift

struct MenuAddCloudAction: Action {
    
    var cloud: CloudType = .google
    
    init(cloud: CloudType) {

        self.cloud = cloud
    }
}
