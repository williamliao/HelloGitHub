//
//  SettingMainItemCell.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/11/3.
//

import UIKit

class SettingMainItemCell: UICollectionViewCell {
    
    static var reuseIdentifier: String {
        return String(describing: SettingMainItemCell.self)
    }
    
    var label: UILabel!
    var button: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        adaptToUserInterfaceStyle()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SettingMainItemCell {
    func configure() {
        
        label = UILabel()

        button = UIButton(type: .custom)
   
        label.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(label)
        self.addSubview(button)
        
        NSLayoutConstraint.activate([
           
            label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            label.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            label.topAnchor.constraint(equalTo: self.topAnchor),
            
            button.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 5),
            button.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            button.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            button.topAnchor.constraint(equalTo: self.topAnchor),
        ])
    }
    
    private func adaptToUserInterfaceStyle() {
        
        let textColor: UIColor = UITraitCollection.current.userInterfaceStyle == .dark ? .white : .black
        let text = UITraitCollection.current.userInterfaceStyle == .dark ? "dark" : "light"
        
        button.setTitle(text, for: .normal)
        button.setTitleColor(textColor, for: .normal)
        
        self.backgroundColor = .tertiarySystemBackground
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        // Trait collection has already changed
        adaptToUserInterfaceStyle()
    }
}
