//
//  SettingProfileItemCell.swift
//  HelloGitHub
//
//  Created by 雲端開發部-廖彥勛 on 2022/1/5.
//

import UIKit

class SettingProfileItemCell: UICollectionViewCell {

    static var reuseIdentifier: String {
        return String(describing: SettingProfileItemCell.self)
    }
    
    var user: UserAccount!
  
    let headerView: UIView = {
        let headerView = UIView()
        headerView.backgroundColor = .systemGray6
        headerView.translatesAutoresizingMaskIntoConstraints = false
        return headerView
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.lineBreakMode = .byTruncatingTail
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let loginNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.lineBreakMode = .byTruncatingTail
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let followingLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.lineBreakMode = .byTruncatingTail
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let followersLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.lineBreakMode = .byTruncatingTail
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let avatarImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.borderWidth = 1
        imageView.layer.masksToBounds = false
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.clipsToBounds = true
        imageView.image = UIImage(systemName: "person.crop.circle")
        return imageView
    }()
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        addConstraints()
        adaptToUserInterfaceStyle()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        avatarImage.layer.cornerRadius = avatarImage.frame.height/2
    }

}

extension SettingProfileItemCell {
    func configure() {
        self.contentView.addSubview(headerView)
        headerView.addSubview(avatarImage)
        headerView.addSubview(nameLabel)
        headerView.addSubview(loginNameLabel)
        headerView.addSubview(followingLabel)
        headerView.addSubview(followersLabel)
    }
    
    func addConstraints() {
        NSLayoutConstraint.activate([
            
            headerView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            headerView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            headerView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
        
            avatarImage.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 10),
            avatarImage.topAnchor.constraint(equalTo: headerView.topAnchor),
            avatarImage.heightAnchor.constraint(equalToConstant: 64),
            avatarImage.widthAnchor.constraint(equalToConstant: 64),
            
            nameLabel.leadingAnchor.constraint(equalTo: avatarImage.trailingAnchor, constant: 5),
            nameLabel.topAnchor.constraint(equalTo: avatarImage.topAnchor, constant: 10),
            nameLabel.heightAnchor.constraint(equalToConstant: 16),
            
            loginNameLabel.leadingAnchor.constraint(equalTo: avatarImage.trailingAnchor, constant: 5),
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            loginNameLabel.heightAnchor.constraint(equalToConstant: 16),
            
            followersLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 15),
            followersLabel.topAnchor.constraint(equalTo: avatarImage.bottomAnchor, constant: 5),
            followersLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -5),

            followingLabel.leadingAnchor.constraint(equalTo: followersLabel.trailingAnchor, constant: 5),
            followingLabel.topAnchor.constraint(equalTo: followersLabel.topAnchor),
            followingLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -5),
            
           
        ])
    }
    
    func configureBindData(item: Bindable<SettingItem>, userInfo: Bindable<UserInfo>) {
        
        item.bind(\.title, to: nameLabel, \.text)
        item.bind(\.subTitle, to: loginNameLabel, \.text)
        item.bind(\.image , to: avatarImage, \.image)
        
        userInfo.bind(\.followers , to: followersLabel, \.text, transform: String.init)
        userInfo.bind(\.following , to: followingLabel, \.text, transform: String.init)
    }
    
    func adaptToUserInterfaceStyle() {
        
    }
}
