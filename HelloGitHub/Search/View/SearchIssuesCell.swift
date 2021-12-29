//
//  SearchIssuesCell.swift
//  HelloGitHub
//
//  Created by 雲端開發部-廖彥勛 on 2021/12/29.
//

import UIKit

class SearchIssuesCell: UITableViewCell {
    
    static var reuseIdentifier: String {
        return String(describing: SearchIssuesCell.self)
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
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.lineBreakMode = .byTruncatingTail
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let conversationLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.lineBreakMode = .byTruncatingTail
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let conversationIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let timeLabel: UILabel = {
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
        titleLabel.text = ""
        conversationLabel.text = ""
        conversationIcon.image = nil
    }

}

extension SearchIssuesCell {
    func configureView() {
        self.contentView.addSubview(userNameLabel)
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(conversationLabel)
        self.contentView.addSubview(conversationIcon)
        self.contentView.addSubview(timeLabel)
    }
    
    func configureConstraints() {
  
        NSLayoutConstraint.activate([
            
            userNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            userNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            userNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            userNameLabel.heightAnchor.constraint(equalToConstant: 16),
            
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            titleLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 10),
            titleLabel.heightAnchor.constraint(equalToConstant: 16),
            
            conversationIcon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            conversationIcon.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            conversationIcon.heightAnchor.constraint(equalToConstant: 21),
            conversationIcon.widthAnchor.constraint(equalToConstant: 21),
            
            conversationLabel.leadingAnchor.constraint(equalTo: conversationIcon.trailingAnchor, constant: 0),
            conversationLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            conversationLabel.heightAnchor.constraint(equalToConstant: 22),
            
            timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            timeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            timeLabel.heightAnchor.constraint(equalToConstant: 16),
        ])
    }
}

extension SearchIssuesCell {
    
    func configureIssuesBindData(item: Bindable<IssuesItems>) {
        item.bind(\.user.login, to: userNameLabel, \.text)
        item.bind(\.title, to: titleLabel, \.text)
        item.bind(\.comments, to: conversationLabel, \.text, transform: String.init)
        item.bind(\.created_at, to: timeLabel, \.text)
        conversationIcon.image = UIImage(systemName: "bubble.left.and.bubble.right.fill")
    }
    
    func formatDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        guard let created_at = timeLabel.text else {
            return
        }
        
        // the date you want to format
        let date = dateFormatter.date(from:created_at)!
     
        // ask for the full relative date
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full

        // get exampleDate relative to the current date
        let relativeDate = formatter.localizedString(for: date, relativeTo: Date())
        
        
        timeLabel.text = relativeDate
    }
}
