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
        case repo
        case main
        case about
        case system
    }
    
    var section: SectionLayoutKind = .profile
    
    var settingProfileTexts = [SettingItem]()
    let settingTexts = [SettingItem(title: "Dark Mode", subTitle: "", image: nil, userInfo: nil)]
    
    let settingAboutTexts = [SettingItem(title: "版本資訊", subTitle: "1.0.0", image: nil, userInfo: nil),                                     SettingItem(title: "使用條款", subTitle: "", image: nil, userInfo: nil),
                             SettingItem(title: "隱私權條款", subTitle: "", image: nil, userInfo: nil)]
    
    var settingRepoTexts = [SettingItem]()
    let settingSystemTexts = [SettingItem(title: "公告", subTitle: "", image: nil, userInfo: nil),                                             SettingItem(title: "登出", subTitle: "", image: nil, userInfo: nil)]
    
    
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
            collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "SettingAboutRepoCell_Id")
            collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "SettingAboutSystemCell_Id")
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
        let configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
            return .list(using: configuration, layoutEnvironment: layoutEnv)
        }
        return UICollectionViewCompositionalLayout(sectionProvider: provider)
    }
    
    func configureDataSource() {
       
        if #available(iOS 14.0, *) {
            
            let configuredProfileCell = UICollectionView.CellRegistration<SettingProfileItemCell, SettingItem> { (cell, indexPath, itemIdentifier) in
                cell.configureBindData(item: .init(itemIdentifier), userInfo: .init(itemIdentifier.userInfo))
            }
            
            let configuredRepoCell = UICollectionView.CellRegistration<UICollectionViewListCell, SettingItem> { (cell, indexPath, itemIdentifier) in
                
                var contentConfiguration = UIListContentConfiguration.valueCell()
                
                contentConfiguration.text = itemIdentifier.title
                contentConfiguration.secondaryText = itemIdentifier.subTitle
                
                contentConfiguration.textProperties.color = .label
                contentConfiguration.secondaryTextProperties.color = .systemGray

                cell.contentConfiguration = contentConfiguration
            }
            
            let configuredMainCell = UICollectionView.CellRegistration<SettingMainItemCell, SettingItem> { (cell, indexPath, itemIdentifier) in
                cell.configureBindData(item: .init(itemIdentifier))
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
            
            let configuredSystemCell = UICollectionView.CellRegistration<UICollectionViewListCell, SettingItem> { (cell, indexPath, itemIdentifier) in
                
                var contentConfiguration = UIListContentConfiguration.valueCell()
                
                contentConfiguration.text = itemIdentifier.title
                contentConfiguration.secondaryText = itemIdentifier.subTitle
                
                contentConfiguration.textProperties.color = .label
                contentConfiguration.secondaryTextProperties.color = .systemGray
                
                if (indexPath.row == 0) {
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
                    case .repo:
                    return collectionView.dequeueConfiguredReusableCell(using: configuredRepoCell, for: indexPath, item: identifier)
                    case .main:
                        return collectionView.dequeueConfiguredReusableCell(using: configuredMainCell, for: indexPath, item: identifier)
                    case .about:
                        return collectionView.dequeueConfiguredReusableCell(using: configuredAboutCell, for: indexPath, item: identifier)
                    case .system:
                        return collectionView.dequeueConfiguredReusableCell(using: configuredSystemCell, for: indexPath, item: identifier)
                    
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
                    case .repo:
                        return collectionView.dequeueReusableCell(withReuseIdentifier: "SettingAboutRepoCell_Id", for: indexPath)
                    case .main:
                        return collectionView.dequeueReusableCell(withReuseIdentifier: SettingMainItemCell.reuseIdentifier, for: indexPath)
                    case .about:
                        return collectionView.dequeueReusableCell(withReuseIdentifier: "SettingAboutItemCell_Id", for: indexPath)
                    case .system:
                        return collectionView.dequeueReusableCell(withReuseIdentifier: "SettingAboutSystemCell_Id", for: indexPath)
                }
            }
        }
    }
    
    func applyInitialSnapshots() {
        
        DispatchQueue.main.async { [weak self] in
            self?.updateModelDataBeforeLoad()
            self?.updateSnapShot()
        }
    }
    
    func updateSnapShot() {
        
        var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, SettingItem>()
        snapshot.appendSections(SectionLayoutKind.allCases)
        dataSource.apply(snapshot, animatingDifferences: false)
        
        if #available(iOS 14.0, *) {
            var profileSnapshot = NSDiffableDataSourceSectionSnapshot<SettingItem>()
            profileSnapshot.append(settingProfileTexts)
            dataSource.apply(profileSnapshot, to: .profile, animatingDifferences: false)
            
            var repoSnapshot = NSDiffableDataSourceSectionSnapshot<SettingItem>()
            repoSnapshot.append(settingRepoTexts)
            dataSource.apply(repoSnapshot, to: .repo, animatingDifferences: false)
            
            var mainSnapshot = NSDiffableDataSourceSectionSnapshot<SettingItem>()
            mainSnapshot.append(settingTexts)
            dataSource.apply(mainSnapshot, to: .main, animatingDifferences: false)
            
            var aboutSnapshot = NSDiffableDataSourceSectionSnapshot<SettingItem>()
            aboutSnapshot.append(settingAboutTexts)
            dataSource.apply(aboutSnapshot, to: .about, animatingDifferences: false)
            
            var systemSnapshot = NSDiffableDataSourceSectionSnapshot<SettingItem>()
            systemSnapshot.append(settingSystemTexts)
            dataSource.apply(systemSnapshot, to: .system, animatingDifferences: false)
        } else {
            // Fallback on earlier versions
            snapshot.appendItems(settingProfileTexts, toSection: .profile)
            snapshot.appendItems(settingRepoTexts, toSection: .repo)
            snapshot.appendItems(settingTexts, toSection: .main)
            snapshot.appendItems(settingAboutTexts, toSection: .about)
            snapshot.appendItems(settingSystemTexts, toSection: .system)
            dataSource.apply(snapshot, animatingDifferences: false, completion: nil)
        }
    }
    
    func updateModelDataBeforeLoad() {
        let name = self.viewModel.user.name ?? ""
        let bio = self.viewModel.user.bio ?? "bio"
        let image = self.viewModel.avatarImage ?? nil

        settingProfileTexts.append(SettingItem(title: name, subTitle: bio, image: image, userInfo: UserInfo(followers: "\(self.viewModel.user.followers) followers", following: "\(self.viewModel.user.following) following")))

        settingRepoTexts.append(SettingItem(title: "Repositories", subTitle:"\(self.viewModel.user.public_repos)" , image: nil, userInfo: nil))
    }
}

extension SettingView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let section = SectionLayoutKind(rawValue: indexPath.section) else {
            return
        }
        
        if section == .system {
            switch indexPath.row {
                case 0:
                    break
                case 1:
                    doLogout()
                default:
                    break
            }
        }
    }
    
    func doLogout() {
        UserDefaults.standard.cleanUserDefault()
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let nav = mainStoryboard.instantiateViewController(withIdentifier: "LoginNav") as? UINavigationController
        
        guard let nav = nav, let window = self.getCurrentWindow() else {
            return
        }
        
        window.rootViewController = nav
        window.makeKeyAndVisible()
        self.setRootViewController(window: window, options: [.transitionFlipFromRight])
    }
}
