//
//  SearchView.swift
//  HelloGitHub
//
//  Created by 雲端開發部-廖彥勛 on 2021/12/27.
//

import UIKit

class SearchView: UIView {
    
    enum Section: Int, CaseIterable {
        case main
    }

    var searchViewController: UISearchController!
    var collectionView: UICollectionView!
    var viewModel: SearchViewModel
    
    init(viewModel: SearchViewModel ) {
        self.viewModel = viewModel
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @available(iOS 13.0, *)
    lazy var searchDataSource  = makeSearchDataSource()
}

// MARK: - View
extension SearchView {
    func createView() {
      
        searchViewController = UISearchController(searchResultsController: nil)
        //searchViewController.searchBar.delegate = self
        searchViewController.obscuresBackgroundDuringPresentation = true
        searchViewController.searchBar.placeholder = "Search"
        searchViewController.definesPresentationContext = true
        searchViewController.searchBar.autocapitalizationType = .none
        searchViewController.obscuresBackgroundDuringPresentation = true
        searchViewController.searchBar.showsScopeBar = true
        searchViewController.isActive = true
    }
    
    func configureCollectionView() {
       
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        
        //collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        makeDateSourceForCollectionView()
        
        collectionView.register(SearchCollectionViewCell.self
                                , forCellWithReuseIdentifier: SearchCollectionViewCell.reuseIdentifier)
        
        
        self.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            collectionView.topAnchor.constraint(equalTo: self.topAnchor),
        ])
    }
    
    func makeDateSourceForCollectionView() {
        collectionView.dataSource = searchDataSource
    }
}

extension SearchView {
    @available(iOS 13.0, *)
    private func getSearchDatasource() -> UICollectionViewDiffableDataSource<Section, Repositories> {
        return searchDataSource
    }
 
    func makeSearchDataSource() -> UICollectionViewDiffableDataSource<Section, Repositories> {
        return UICollectionViewDiffableDataSource<Section, Repositories>(collectionView: collectionView) { (collectionView, indexPath, respone) -> SearchCollectionViewCell? in
            let cell = self.configureSearchCell(collectionView: collectionView, respone: respone, indexPath: indexPath)
            return cell
        }
    }
}

extension SearchView {
    func configureSearchCell(collectionView: UICollectionView, respone: Repositories, indexPath: IndexPath) -> SearchCollectionViewCell? {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchCollectionViewCell.reuseIdentifier, for: indexPath) as? SearchCollectionViewCell
        
        
        
        return cell
    }
}
