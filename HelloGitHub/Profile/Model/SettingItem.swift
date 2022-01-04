//
//  SettingItem.swift
//  HelloGitHub
//
//  Created by 雲端開發部-廖彥勛 on 2022/1/4.
//

import UIKit

struct SettingItem: Hashable {
    let title: String
    let subTitle: String
    let image: UIImage?
    private let id = UUID()

    init(title: String, subTitle: String, image: UIImage?) {
        self.title = title
        self.subTitle = subTitle
        self.image = image
    }
}
