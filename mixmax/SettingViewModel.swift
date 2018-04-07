//
//  SettingViewModel.swift
//  mixmax
//
//  Created by Vinh Nguyen on 4/7/18.
//  Copyright © 2018 Vinh Nguyen. All rights reserved.
//

struct SettingViewModel {
    
    var clouds: [CloudType]
    
    var cellViewModels: [SettingCellViewModel]? {
        return clouds.map { map(cloud: $0) }
    }
    
    init(clouds: [CloudType]) {
        self.clouds = clouds
    }
    
    private func map(cloud: CloudType) -> SettingCellViewModel {
        switch cloud {
        case .dropbox:
            return SettingCellViewModel(title: "Dropbox", imageName: "dropbox", isActive: DropboxClient.isAuthorize)
        case .google:
            return SettingCellViewModel(title: "Google drive", imageName: "google", isActive: GoogleClient.isAuthorize)
        default:
            return SettingCellViewModel(title: "", imageName: "", isActive: false)
        }
    }
    
    private func authorize(cloud: CloudType) {
        
    }
}
