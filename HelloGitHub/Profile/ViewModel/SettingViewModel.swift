//
//  SettingViewModel.swift
//  HelloGitHub
//
//  Created by 雲端開發部-廖彥勛 on 2022/1/4.
//

import Foundation

class SettingViewModel {
    
    private let dataLoader: DataLoader
    
    var reloadData: (() -> Void)?
    var showError: ((_ error:NetworkError) -> Void)?
    
    init(dataLoader: DataLoader) {
        self.dataLoader = dataLoader
    }
}

extension SettingViewModel {
    
}
