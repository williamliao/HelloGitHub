//
//  SearchRepositoriesCell.swift
//  HelloGitHub
//
//  Created by 雲端開發部-廖彥勛 on 2021/12/29.
//

import UIKit

class SearchRepositoriesCell: UITableViewCell {
    
    static var reuseIdentifier: String {
        return String(describing: SearchRepositoriesCell.self)
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
        label.lineBreakMode = .byWordWrapping
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
    
    private var likeLabelWidthLayoutConstraint: NSLayoutConstraint!
   
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
        likeIcon.image = nil
    }
}

extension SearchRepositoriesCell {
    func configureView() {
        self.contentView.addSubview(userNameLabel)
        self.contentView.addSubview(nameLabel)
        self.contentView.addSubview(descriptionLabel)
        self.contentView.addSubview(likeLabel)
        self.contentView.addSubview(likeIcon)
        self.contentView.addSubview(languageLabel)
    }
    
    func configureConstraints() {
        
        likeLabelWidthLayoutConstraint = likeLabel.widthAnchor.constraint(equalToConstant: 50)
        
        NSLayoutConstraint.activate([
            
            userNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            userNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            userNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            userNameLabel.heightAnchor.constraint(equalToConstant: 16),
            
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            nameLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 5),
            nameLabel.heightAnchor.constraint(equalToConstant: 16),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            descriptionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            
            likeIcon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            likeIcon.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 5),
            likeIcon.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            
            likeLabel.leadingAnchor.constraint(equalTo: likeIcon.trailingAnchor, constant: 0),
            likeLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 5),
            likeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            likeLabel.heightAnchor.constraint(equalToConstant: 16),
            likeLabelWidthLayoutConstraint,
    
            languageLabel.leadingAnchor.constraint(equalTo: likeLabel.trailingAnchor, constant: 5),
            languageLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 5),
            languageLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            languageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
        ])
    }
}

extension SearchRepositoriesCell {
    
    func configureBindData(repo: Bindable<Item>) {
        repo.bind(\.full_name, to: userNameLabel, \.text)
        repo.bind(\.name, to: nameLabel, \.text)
        repo.bind(\.description, to: descriptionLabel, \.text)
        repo.bind(\.stargazers_count, to: likeLabel, \.text, transform: String.init)
        repo.bind(\.language, to: languageLabel, \.text)
        
        let font = UIFont.systemFont(ofSize: 12)
        let configuration = UIImage.SymbolConfiguration(font: font)
        likeIcon.image = UIImage(systemName: "star", withConfiguration: configuration)

        let labelSize = likeLabel.calculateLabelFrame(font: likeLabel.font)
        likeLabelWidthLayoutConstraint.constant = labelSize.width
    }
    
    func configureCommitsBindData(repo: Bindable<CommitItem>) {
        repo.bind(\.commit.committer.name, to: userNameLabel, \.text)
        repo.bind(\.commit.message, to: descriptionLabel, \.text)
    }
}
