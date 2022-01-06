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
    private var act = UIActivityIndicatorView(style: .large)
    private var spinner = UIActivityIndicatorView(style: .large)
    
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
    private var searchUsersDataSource: UITableViewDiffableDataSource<Section, UsersInfo>!
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
        searchViewController.searchBar.placeholder = "Search GitHub"
        searchViewController.searchBar.scopeButtonTitles = SearchResults.SearchType.allCases.map { $0.rawValue }
        
        navItem.searchController = searchViewController
        searchViewController.hidesNavigationBarDuringPresentation = false
        navItem.hidesSearchBarWhenScrolling = false
    }
    
    func configureTableView() {
       
        tableView = UITableView()
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.estimatedRowHeight = 150
        tableView.rowHeight = UITableView.automaticDimension

        tableView.register(SearchRepositoriesCell.self, forCellReuseIdentifier: SearchRepositoriesCell.reuseIdentifier)
        tableView.register(SearchIssuesCell.self, forCellReuseIdentifier: SearchIssuesCell.reuseIdentifier)
        tableView.register(SearchUsersCell.self, forCellReuseIdentifier: SearchUsersCell.reuseIdentifier)
        
        act.color = traitCollection.userInterfaceStyle == .light ? UIColor.black : UIColor.white
        act.translatesAutoresizingMaskIntoConstraints = false
      
        self.addSubview(tableView)
        self.addSubview(act)
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            tableView.topAnchor.constraint(equalTo: self.topAnchor),
            
            act.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            act.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        ])
        
        viewModel.reloadTableView = { [weak self] in
            DispatchQueue.main.async {
                self?.isLoading(isLoading: false)
                self?.isSpinnerLoading(isLoading: false)
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
        
        searchDataSource = UITableViewDiffableDataSource<Section, Item>(tableView: tableView, cellProvider: { (tableView, indexPath, item) -> SearchRepositoriesCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: SearchRepositoriesCell.reuseIdentifier, for: indexPath) as? SearchRepositoriesCell
            cell?.configureBindData(repo: .init(item))
            return cell
        })
        
        searchIssuesDataSource = UITableViewDiffableDataSource<Section, IssuesItems>(tableView: tableView, cellProvider: { (tableView, indexPath, issues) -> SearchIssuesCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: SearchIssuesCell.reuseIdentifier, for: indexPath) as? SearchIssuesCell
            cell?.configureIssuesBindData(item: .init(issues))
            
            cell?.formatDate(issues.created_at)
            
            return cell
        })
        
        searchUsersDataSource = UITableViewDiffableDataSource<Section, UsersInfo>(tableView: tableView, cellProvider: { (tableView, indexPath, users) -> SearchUsersCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: SearchUsersCell.reuseIdentifier, for: indexPath) as? SearchUsersCell
            cell?.configureBindData(users: .init(users), imageUrl: users.avatar_url)
            return cell
        })
    }
  
    @available(iOS 13.0, *)
    func applyInitialSnapshots() {
        
        DispatchQueue.main.async { [weak self] in
            
            guard let searchType = self?.viewModel.searchType else {
                return
            }
            
            switch searchType {
                case .repositories:
                    self?.configureRepo()
                case .issues, .PRs:
                    self?.configureIssues()
                case .people, .organizations:
                    self?.configureUser()
            }
        }
    }
    
    func configureRepo() {
        
        tableView.dataSource = searchDataSource
        
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
    
    func configureUser() {
        
        tableView.dataSource = searchUsersDataSource
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, UsersInfo>()
 
        //Append available sections
        Section.allCases.forEach { snapshot.appendSections([$0]) }
        
        if viewModel.usersInfo.count > 0 {
            snapshot.appendItems(viewModel.usersInfo, toSection: .main)
        } else {
            snapshot.appendItems([], toSection: .main)
        }
        
        searchUsersDataSource.apply(snapshot, animatingDifferences: false)
    }
}

// MARK: - UICollectionView Delegate
extension SearchView: UITableViewDelegate, UIScrollViewDelegate {
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastElement = tableView.numberOfRows(inSection: indexPath.section) - 1
        cellHeightsDictionary[indexPath] = cell.frame.size.height
        
        if !viewModel.isFetching && indexPath.row == lastElement {
            
            isSpinnerLoading(isLoading: true)
            spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))

            self.tableView.tableFooterView = spinner
            self.tableView.tableFooterView?.isHidden = false
            
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
        
        isLoading(isLoading: true)
        
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
        
        closeSearchView()
        
        isLoading(isLoading: true)
        viewModel.searchType = category
        viewModel.querySearch(query: strippedString)
    }
    
    func closeSearchView() {
        viewModel.repo = nil
        isLoading(isLoading: false)
        isSpinnerLoading(isLoading: false)
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

extension SearchView {
    func isLoading(isLoading: Bool) {
        if isLoading {
            act.startAnimating()
        } else {
            act.stopAnimating()
        }
        act.isHidden = !isLoading
    }
    
    func isSpinnerLoading(isLoading: Bool) {
        if isLoading {
            spinner.startAnimating()
        } else {
            spinner.stopAnimating()
        }
        spinner.isHidden = !isLoading
    }
}
