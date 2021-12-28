//
//  SearchView.swift
//  HelloGitHub
//
//  Created by 雲端開發部-廖彥勛 on 2021/12/27.
//

import UIKit

class SearchView: UIView {
    
    private enum Section: CaseIterable {
        case main
    }

    var searchViewController: UISearchController!
    var tableView: UITableView!
    var viewModel: SearchViewModel
    var navItem: UINavigationItem
    
    init(viewModel: SearchViewModel,  navItem: UINavigationItem) {
        self.viewModel = viewModel
        self.navItem = navItem
        super.init(frame: CGRect.zero)
        createView()
        configureTableView()
        makeDateSourceForCollectionView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var searchDataSource: UITableViewDiffableDataSource<Section, Item>!
    
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
        
        navItem.searchController = searchViewController
        searchViewController.hidesNavigationBarDuringPresentation = false
        navItem.hidesSearchBarWhenScrolling = false
    }
    
    func configureTableView() {
       
        tableView = UITableView()
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.register(SearchTableViewCell.self, forCellReuseIdentifier: SearchTableViewCell.reuseIdentifier)
      
        self.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            tableView.topAnchor.constraint(equalTo: self.topAnchor),
        ])
        
        viewModel.reloadTableView = { [weak self] in
            DispatchQueue.main.async {
                self?.applyInitialSnapshots()
            }
        }
    }
    
    func makeDateSourceForCollectionView() {
        makeSearchDataSource()
        tableView.dataSource = getSearchDatasource()
    }
}

// MARK: - DataSource
extension SearchView {
    
    private func getSearchDatasource() -> UITableViewDiffableDataSource<Section, Item> {
        return searchDataSource
    }
 
    private func makeSearchDataSource() {
        
        searchDataSource = UITableViewDiffableDataSource<Section, Item>(tableView: tableView, cellProvider: { (tableView, indexPath, item) -> SearchTableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: SearchTableViewCell.reuseIdentifier, for: indexPath) as? SearchTableViewCell
            cell?.configureBindData(repo: .init(item))
            return cell
        })
    }
    
    @available(iOS 13.0, *)
    func applyInitialSnapshots() {

        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        //var dataSource = getSearchDatasource()
        
        
        //Append available sections
        Section.allCases.forEach { snapshot.appendSections([$0]) }

        guard let results = viewModel.repo else {
            return
        }
        
        snapshot.appendItems(results.items, toSection: .main)
        
        UIView.animate(withDuration: 0.25, delay: 0, options: UIView.AnimationOptions.curveLinear) {
            self.searchDataSource.apply(snapshot, animatingDifferences: false)
        } completion: { success in
            
        }
    }
}

// MARK: - UICollectionView Delegate
extension SearchView: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}

// MARK: - Private
