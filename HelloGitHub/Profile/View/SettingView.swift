//
//  SettingView.swift
//  HelloGitHub
//
//  Created by 雲端開發部-廖彥勛 on 2022/1/4.
//

import UIKit

class SettingView: UIView {
    
    var viewModel: SettingViewModel
    
    init(viewModel: SettingViewModel) {
        self.viewModel = viewModel
        super.init(frame: CGRect.zero)
        configureHierarchy()
        configureDataSource()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    enum SectionLayoutKind: Int, CaseIterable, Hashable {
        case profile
        case main
        case about
    }
    
    var section: SectionLayoutKind = .profile
    
    var settingProfileTexts = [SettingItem]()
    let settingTexts = [SettingItem(title: "Dark Mode", subTitle: "", image: nil)]
    let settingAboutTexts = [SettingItem(title: "版本資訊", subTitle: "1.0.0", image: nil), SettingItem(title: "使用條款", subTitle: "", image: nil), SettingItem(title: "隱私權條款", subTitle: "", image: nil)]
    var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, SettingItem>! = nil
    var collectionView: UICollectionView! = nil

}

extension SettingView {
    
    func configureHierarchy() {
        if #available(iOS 14.0.0, *) {
            collectionView = UICollectionView(frame: .zero, collectionViewLayout: configureLayout())
        } else {
            // Fallback on earlier versions
            let flowLayout = UICollectionViewFlowLayout()
            collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
            
            collectionView.register(SettingProfileItemCell.self, forCellWithReuseIdentifier: SettingProfileItemCell.reuseIdentifier)
            collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "SettingAboutItemCell_Id")
            collectionView.register(SettingMainItemCell.self, forCellWithReuseIdentifier: SettingMainItemCell.reuseIdentifier)
        }
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self.dataSource
        collectionView.delegate = self
        
        self.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: self.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    @available(iOS 14.0.0, *)
    func configureLayout() -> UICollectionViewLayout {
        let provider = {(_: Int, layoutEnv: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
        let configuration = UICollectionLayoutListConfiguration(appearance: .grouped)
            return .list(using: configuration, layoutEnvironment: layoutEnv)
        }
        return UICollectionViewCompositionalLayout(sectionProvider: provider)
    }
    
    func configureDataSource() {
       
        if #available(iOS 14.0, *) {
            
            let configuredProfileCell = UICollectionView.CellRegistration<SettingProfileItemCell, SettingItem> { (cell, indexPath, itemIdentifier) in
                
                cell.nameLabel.text = itemIdentifier.title
                cell.loginNameLabel.text = itemIdentifier.subTitle
                
                if let avatarImage = itemIdentifier.image {
                    cell.avatarImage.image = avatarImage
                }
                
                cell.followersLabel.text = "\(self.viewModel.user.followers) followers"
                cell.followingLabel.text = "\(self.viewModel.user.following) following"
                
               /* var contentConfiguration = UIListContentConfiguration.subtitleCell()
                
                contentConfiguration.text = itemIdentifier.title
                contentConfiguration.secondaryText = itemIdentifier.subTitle
                
                contentConfiguration.textProperties.color = .label
                contentConfiguration.secondaryTextProperties.color = .systemGray
                
                if let avatarImage = itemIdentifier.image {
                    contentConfiguration.image = avatarImage
                }
                
                cell.contentConfiguration = contentConfiguration*/
            }
            
            let configuredMainCell = UICollectionView.CellRegistration<SettingMainItemCell, SettingItem> { (cell, indexPath, itemIdentifier) in
                cell.label.text = itemIdentifier.title
                
            }
            
            let configuredAboutCell = UICollectionView.CellRegistration<UICollectionViewListCell, SettingItem> { (cell, indexPath, itemIdentifier) in
                var contentConfiguration = UIListContentConfiguration.valueCell()
                
                contentConfiguration.text = itemIdentifier.title
                contentConfiguration.secondaryText = itemIdentifier.subTitle
                
                contentConfiguration.textProperties.color = .label
                contentConfiguration.secondaryTextProperties.color = .systemGray

                if (indexPath.row != 0) {
                    // 1
                    let options = UICellAccessory.OutlineDisclosureOptions(style: .header)
                    // 2
                    let disclosureAccessory = UICellAccessory.outlineDisclosure(options: options)
                    // 3
                    cell.accessories = [disclosureAccessory]
                }
                
                cell.contentConfiguration = contentConfiguration
            }
            
            dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, SettingItem>(collectionView: collectionView) {
                (collectionView: UICollectionView, indexPath: IndexPath, identifier: SettingItem) -> UICollectionViewCell? in
                // Return the cell.
                guard let section = SectionLayoutKind(rawValue: indexPath.section) else {
                    return nil
                }
                
                switch section {
                    case .profile:
                        return collectionView.dequeueConfiguredReusableCell(using: configuredProfileCell, for: indexPath, item: identifier)
                    case .main:
                        return collectionView.dequeueConfiguredReusableCell(using: configuredMainCell, for: indexPath, item: identifier)
                    case .about:
                        return collectionView.dequeueConfiguredReusableCell(using: configuredAboutCell, for: indexPath, item: identifier)
                }
            }
            
        } else {
            // Fallback on earlier versions
            
            dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, SettingItem>(collectionView: collectionView) {
                (collectionView: UICollectionView, indexPath: IndexPath, identifier: SettingItem) -> UICollectionViewCell? in
                // Return the cell.
                guard let section = SectionLayoutKind(rawValue: indexPath.section) else {
                    return nil
                }
                
                switch section {
                    case .profile:
                    return collectionView.dequeueReusableCell(withReuseIdentifier: SettingProfileItemCell.reuseIdentifier, for: indexPath)
                    case .main:
                        return collectionView.dequeueReusableCell(withReuseIdentifier: SettingMainItemCell.reuseIdentifier, for: indexPath)
                    case .about:
                        return collectionView.dequeueReusableCell(withReuseIdentifier: "SettingAboutItemCell_Id", for: indexPath)
                }
            }
        }
    }
    
    func applyInitialSnapshots() {
        // initial data
        var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, SettingItem>()
        snapshot.appendSections(SectionLayoutKind.allCases)
        dataSource.apply(snapshot, animatingDifferences: false)
        
        let name = self.viewModel.user.name ?? ""
        let bio = self.viewModel.user.bio ?? "bio"
        let image = self.viewModel.avatarImage ?? nil
        settingProfileTexts.append(SettingItem(title: name, subTitle: bio, image: image))
        
        if #available(iOS 14.0, *) {
            var profileSnapshot = NSDiffableDataSourceSectionSnapshot<SettingItem>()
            profileSnapshot.append(settingProfileTexts)
            dataSource.apply(profileSnapshot, to: .profile, animatingDifferences: false)
            
            var mainSnapshot = NSDiffableDataSourceSectionSnapshot<SettingItem>()
            mainSnapshot.append(settingTexts)
            dataSource.apply(mainSnapshot, to: .main, animatingDifferences: false)
            
            var aboutSnapshot = NSDiffableDataSourceSectionSnapshot<SettingItem>()
            aboutSnapshot.append(settingAboutTexts)
            dataSource.apply(aboutSnapshot, to: .about, animatingDifferences: false)
        } else {
            // Fallback on earlier versions
            snapshot.appendItems(settingProfileTexts, toSection: .profile)
            snapshot.appendItems(settingTexts, toSection: .main)
            snapshot.appendItems(settingAboutTexts, toSection: .about)
            dataSource.apply(snapshot, animatingDifferences: false, completion: nil)
        }
    }
}

extension SettingView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 150)
    }
}

extension SettingView: UICollectionViewDelegate {}
