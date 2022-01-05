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
        imageView.layer.borderColor = UIColor.black.cgColor
        imageView.layer.cornerRadius = imageView.frame.height/2
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

}

extension SettingProfileItemCell {
    func configure() {
        self.contentView.addSubview(avatarImage)
        self.contentView.addSubview(nameLabel)
        self.contentView.addSubview(loginNameLabel)
        self.contentView.addSubview(followingLabel)
        self.contentView.addSubview(followersLabel)
    }
    
    func addConstraints() {
        NSLayoutConstraint.activate([
           
            avatarImage.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            avatarImage.topAnchor.constraint(equalTo: self.topAnchor),
            avatarImage.heightAnchor.constraint(equalToConstant: 44),
            avatarImage.widthAnchor.constraint(equalToConstant: 44),
            
            nameLabel.leadingAnchor.constraint(equalTo: avatarImage.trailingAnchor, constant: 5),
            nameLabel.topAnchor.constraint(equalTo: avatarImage.topAnchor),
            nameLabel.heightAnchor.constraint(equalToConstant: 16),
            
            loginNameLabel.leadingAnchor.constraint(equalTo: avatarImage.trailingAnchor, constant: 5),
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            loginNameLabel.heightAnchor.constraint(equalToConstant: 16),
            
            followersLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5),
            followersLabel.topAnchor.constraint(equalTo: avatarImage.bottomAnchor, constant: 5),
            followersLabel.heightAnchor.constraint(equalToConstant: 16),
            
            followingLabel.leadingAnchor.constraint(equalTo: followersLabel.trailingAnchor, constant: 5),
            followingLabel.topAnchor.constraint(equalTo: followersLabel.bottomAnchor),
            followingLabel.heightAnchor.constraint(equalToConstant: 16),
        ])
    }
    
    func adaptToUserInterfaceStyle() {
        
    }
}
