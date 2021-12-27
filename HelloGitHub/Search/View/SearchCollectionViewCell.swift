//
//  SearchCollectionViewCell.swift
//  HelloGitHub
//
//  Created by 雲端開發部-廖彥勛 on 2021/12/27.
//

import UIKit

class SearchCollectionViewCell: UICollectionViewCell {
    static var reuseIdentifier: String {
        return String(describing: SearchCollectionViewCell.self)
    }
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.lineBreakMode = .byTruncatingTail
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
        configureConstraints()
    }
}

// MARK:- View
extension SearchCollectionViewCell {
    
    func configureView() {
        
        self.contentView.addSubview(nameLabel)
    }
    
    func configureConstraints() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
          
        ])
    }
}

// MARK:- private
extension SearchCollectionViewCell {
    
    func configureCell(with repo: Item) {
        nameLabel.text = repo.name
    }
}
