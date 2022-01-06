//
//  UserDefaults+UtilityTool.swift
//  HelloGitHub
//
//  Created by 雲端開發部-廖彥勛 on 2022/1/6.
//

import Foundation

extension UserDefaults {
    
    func cleanUserDefault() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
            defaults.dictionaryRepresentation().keys.forEach(defaults.removeObject(forKey:))
        }
    }
}
