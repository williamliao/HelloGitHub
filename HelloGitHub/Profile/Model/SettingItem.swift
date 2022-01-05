//
//  SettingItem.swift
//  HelloGitHub
//
//  Created by 雲端開發部-廖彥勛 on 2022/1/4.
//

import UIKit

struct SettingItem {
    let title: String
    let subTitle: String
    let image: UIImage?
    var userInfo: UserInfo?
    private var id = UUID()

    init(title: String, subTitle: String, image: UIImage?, userInfo: UserInfo?) {
        self.title = title
        self.subTitle = subTitle
        self.image = image
        self.userInfo = userInfo
    }
}

extension SettingItem: Hashable, Equatable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: SettingItem, rhs: SettingItem) -> Bool {
        return lhs.id == rhs.id
    }
}

struct UserInfo: Codable {
    private var id = UUID()
    let followers: String
    let following: String
    
    init(followers: String, following: String) {
        self.followers = followers
        self.following = following
    }
}

extension UserInfo: Hashable, Equatable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: UserInfo, rhs: UserInfo) -> Bool {
        return lhs.id == rhs.id
    }
}
