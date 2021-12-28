//
//  SearchTableViewCell.swift
//  HelloGitHub
//
//  Created by 雲端開發部-廖彥勛 on 2021/12/28.
//

import UIKit

class SearchTableViewCell: UITableViewCell {
    
    var repo: Bindable<Item>!
    
    static var reuseIdentifier: String {
        return String(describing: SearchTableViewCell.self)
    }
    
    let userNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.lineBreakMode = .byTruncatingTail
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.lineBreakMode = .byTruncatingTail
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let likeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.lineBreakMode = .byTruncatingTail
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let likeIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let languageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.lineBreakMode = .byTruncatingTail
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        userNameLabel.text = ""
        nameLabel.text = ""
        descriptionLabel.text = ""
        likeLabel.text = ""
        languageLabel.text = ""
    }
}

extension SearchTableViewCell {
    func configureView() {
        self.contentView.addSubview(userNameLabel)
        self.contentView.addSubview(nameLabel)
        self.contentView.addSubview(descriptionLabel)
        self.contentView.addSubview(likeLabel)
        self.contentView.addSubview(likeIcon)
        self.contentView.addSubview(languageLabel)
    }
    
    func configureConstraints() {
  
        NSLayoutConstraint.activate([
            
            userNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            userNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            userNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            userNameLabel.heightAnchor.constraint(equalToConstant: 16),
            
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            nameLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 10),
            nameLabel.heightAnchor.constraint(equalToConstant: 16),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            descriptionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            descriptionLabel.heightAnchor.constraint(equalToConstant: 16),
            
            likeIcon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            likeIcon.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 10),
            likeIcon.heightAnchor.constraint(equalToConstant: 22),
            likeIcon.widthAnchor.constraint(equalToConstant: 22),
            
            likeLabel.leadingAnchor.constraint(equalTo: likeIcon.trailingAnchor, constant: 0),
            likeLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 10),
            likeLabel.heightAnchor.constraint(equalToConstant: 22),
    
            languageLabel.leadingAnchor.constraint(equalTo: likeLabel.trailingAnchor, constant: 5),
            languageLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 10),
            languageLabel.heightAnchor.constraint(equalToConstant: 22),
            languageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
        ])
    }
}

extension SearchTableViewCell {
    
    func configureBindData(repo: Bindable<Item>) {
        repo.bind(\.full_name, to: userNameLabel, \.text)
        repo.bind(\.name, to: nameLabel, \.text)
        repo.bind(\.description, to: descriptionLabel, \.text)
        repo.bind(\.stargazers_count, to: likeLabel, \.text, transform: String.init)
        repo.bind(\.language, to: languageLabel, \.text)
        
        likeIcon.image = UIImage(systemName: "star")
    }
    
    func configureCommitsBindData(repo: Bindable<CommitItem>) {
        repo.bind(\.commit.committer.name, to: userNameLabel, \.text)
        repo.bind(\.commit.message, to: descriptionLabel, \.text)
    }
}
