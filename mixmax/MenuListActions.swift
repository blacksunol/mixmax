//
//  MenuListActions.swift
//  mixmax
//
//  Created by Vinh Nguyen on 4/5/18.
//  Copyright © 2018 Vinh Nguyen. All rights reserved.
//

import ReactiveReSwift

struct MenuAddCloudAction: Action {

    let cloud: Cloud
}

struct MenuRemoveCloudAction: Action {
    
    let cloud: Cloud
}

struct InitCloudsAction: Action {
    
    let clouds: [Cloud]
}

struct SelectedCloudAction: Action {
    
    let cloud: Cloud
}

struct SelectedFeatureAction: Action {
    
    let feature: String
}
