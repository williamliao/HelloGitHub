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
    var cellHeightsDictionary: [IndexPath: CGFloat] = [:]
    
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
    private var searchIssuesDataSource: UITableViewDiffableDataSource<Section, IssuesItems>!
}

// MARK: - View
extension SearchView {
    func createView() {
      
        searchViewController = UISearchController(searchResultsController: nil)
        searchViewController.searchBar.delegate = self
        searchViewController.obscuresBackgroundDuringPresentation = true
        searchViewController.definesPresentationContext = true
        searchViewController.searchBar.autocapitalizationType = .none
        searchViewController.obscuresBackgroundDuringPresentation = true
        searchViewController.searchBar.showsScopeBar = true
        searchViewController.isActive = true
        //searchViewController.searchResultsUpdater = self
        searchViewController.searchBar.placeholder = "Type something here to search"
        searchViewController.searchBar.scopeButtonTitles = SearchResults.SearchType.allCases.map { $0.rawValue }
        
        navItem.searchController = searchViewController
        searchViewController.hidesNavigationBarDuringPresentation = false
        navItem.hidesSearchBarWhenScrolling = false
    }
    
    func configureTableView() {
       
        tableView = UITableView()
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.register(SearchRepositoriesCell.self, forCellReuseIdentifier: SearchRepositoriesCell.reuseIdentifier)
        tableView.register(SearchIssuesCell.self, forCellReuseIdentifier: SearchIssuesCell.reuseIdentifier)
      
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
        makeSearchIssuesDataSource()
        tableView.dataSource = getSearchDatasource()
    }
}

// MARK: - DataSource
extension SearchView {
    
    private func getSearchDatasource() -> UITableViewDiffableDataSource<Section, Item> {
        return searchDataSource
    }
 
    private func makeSearchDataSource() {
        
        searchDataSource = UITableViewDiffableDataSource<Section, Item>(tableView: tableView, cellProvider: { (tableView, indexPath, item) -> SearchRepositoriesCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: SearchRepositoriesCell.reuseIdentifier, for: indexPath) as? SearchRepositoriesCell
            cell?.configureBindData(repo: .init(item))
            return cell
        })
    }
    
    private func makeSearchIssuesDataSource() {
        
        searchIssuesDataSource = UITableViewDiffableDataSource<Section, IssuesItems>(tableView: tableView, cellProvider: { (tableView, indexPath, issues) -> SearchIssuesCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: SearchIssuesCell.reuseIdentifier, for: indexPath) as? SearchIssuesCell
            cell?.configureIssuesBindData(item: .init(issues))
            
            cell?.formatDate(issues.created_at)
            
            return cell
        })
    }
    
    @available(iOS 13.0, *)
    func applyInitialSnapshots() {

        switch viewModel.searchType {
            
            case .repositories:
                configureRepo()
            case .issues:
                configureIssues()
            default:
                break
        }

    }
    
    func configureRepo() {
        
        //tableView.dataSource = searchDataSource
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
 
        //Append available sections
        Section.allCases.forEach { snapshot.appendSections([$0]) }
        
        if let results = viewModel.repo {
            snapshot.appendItems(results.items, toSection: .main)
        } else {
            snapshot.appendItems([], toSection: .main)
        }
        
        searchDataSource.apply(snapshot, animatingDifferences: false)
    }
    
    func configureIssues() {
        
        tableView.dataSource = searchIssuesDataSource
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, IssuesItems>()
 
        //Append available sections
        Section.allCases.forEach { snapshot.appendSections([$0]) }
    
        if let results = viewModel.issues {
            snapshot.appendItems(results.items, toSection: .main)
        } else {
            snapshot.appendItems([], toSection: .main)
        }
        
        searchIssuesDataSource.apply(snapshot, animatingDifferences: false)
    }
}

// MARK: - UICollectionView Delegate
extension SearchView: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastElement = tableView.numberOfRows(inSection: indexPath.section) - 1
        
        if indexPath.row == lastElement {
            self.cellHeightsDictionary[indexPath] = cell.frame.size.height
            viewModel.loadNextPage()
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if let height =  self.cellHeightsDictionary[indexPath]{
            return height
        }
        return UITableView.automaticDimension
    }
}

// MARK: - UISearchBarDelegate

extension SearchView: UISearchBarDelegate {
   
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
   
        guard let searchText = searchBar.text else {
            return
        }
        
        // Strip out all the leading and trailing spaces.
        let whitespaceCharacterSet = CharacterSet.whitespaces
        let strippedString =
            searchText.trimmingCharacters(in: whitespaceCharacterSet)
        
        guard let category = SearchResults.SearchType(rawValue:searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]) else {
            return
        }
        
        viewModel.searchType = category
       
        viewModel.querySearch(query: strippedString)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        closeSearchView()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            closeSearchView()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        
        self.cellHeightsDictionary = [IndexPath: CGFloat]()
        
//        switch selectedScope {
//            case 0:
//                viewModel.searchType = .repositories
//            case 1:
//                viewModel.searchType = .code
//            case 2:
//                viewModel.searchType = .commits
//            case 3:
//                viewModel.searchType = .issues
//            case 4:
//                viewModel.searchType = .labels
//            case 5:
//                viewModel.searchType = .topics
//            case 6:
//                viewModel.searchType = .users
//            default:
//                break
//        }
        
        guard let scopeButtonTitles = searchBar.scopeButtonTitles else {
            return
        }
        
        guard let category = SearchResults.SearchType(rawValue:
                                                        scopeButtonTitles[selectedScope]) else {
            return
        }
        
        guard let searchText = searchBar.text, !searchText.isEmpty else {
            return
        }
        
        // Strip out all the leading and trailing spaces.
        let whitespaceCharacterSet = CharacterSet.whitespaces
        let strippedString =
            searchText.trimmingCharacters(in: whitespaceCharacterSet)
        
        viewModel.reset()
        
        viewModel.searchType = category
       
        viewModel.querySearch(query: strippedString)
    }
    
    func closeSearchView() {
        viewModel.repo = nil
        viewModel.reset()
        self.applyInitialSnapshots()
        self.endEditing(true)
    }
}

extension SearchView: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard searchController.isActive else { return }
        guard let searchText = searchController.searchBar.text else {
            return
        }
        
        viewModel.querySearch(query: searchText)
    }
}

// MARK: - Private
