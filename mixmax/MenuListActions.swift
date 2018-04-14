//
//  MenuListActions.swift
//  mixmax
//
//  Created by Vinh Nguyen on 4/5/18.
//  Copyright © 2018 Vinh Nguyen. All rights reserved.
//

import ReactiveReSwift

struct MenuAddCloudAction: Action {

    let cloud: CloudType
}

struct MenuRemoveCloudAction: Action {
    
    let cloud: CloudType
}

struct InitCloudsAction: Action {
    
    let clouds: [CloudType]
}

struct SelectedCloudAction: Action {
    
    let cloud: CloudType 
}

struct SelectedFeatureAction: Action {
    
    let feature: String
}
