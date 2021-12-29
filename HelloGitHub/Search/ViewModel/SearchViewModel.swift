//
//  SearchViewModel.swift
//  HelloGitHub
//
//  Created by 雲端開發部-廖彥勛 on 2021/12/27.
//

import UIKit

class SearchViewModel {
    
    private var loadingTask: Task<Void, Never>?
    
    var repo: Repositories!
    var issues: Issues!
    
    var reloadTableView: (() -> Void)?
    var showError: ((_ error:NetworkError) -> Void)?

    var searchType: SearchResults.SearchType = .repositories
    
    private let dataLoader: DataLoader
    private var searchText: String!
    private(set) var isFetching = false
    private var canFetchMore = true
    
    private var perPage: Int = 30
    private var currentPage: Int = 2

    init(dataLoader: DataLoader) {
        self.dataLoader = dataLoader
    }
  
    func querySearch(query: String) {
        
        if isFetching {
            return
        }
        
        searchText = query
        
        isFetching = true
        
        switch searchType {
            case .repositories:
                Task {
                    await searchRepositories()
                }
            case .issues:
                Task {
                    await searchIssues()
                }
                break
            default:
                break
        }
    }
    
    func reset() {
        isFetching = false
        canFetchMore = true
        currentPage = 2
    }
}

// MARK: - Search By Type
extension SearchViewModel {
    func searchRepositories() async {

        dataLoader.decoder.dateDecodingStrategy = .iso8601
        
        do {
            let result = try await dataLoader.fetch(EndPoint.search(matching: searchText), decode: { json -> Repositories? in
                guard let feedResult = json as? Repositories else { return  nil }
                return feedResult
            })
            
            isFetching = false
            switch result {
                case .success(let repo):
            
                    
                    self.repo = repo
                    self.reloadTableView?()
                    
                case .failure(let error):
                    showError?(error)
            }
            
        } catch  {
            print("searchRepositories error \(error)")
        }
    }
    
    func searchCode() {
        
    }
    
    func searchIssues() async {
        
        dataLoader.decoder.dateDecodingStrategy = .iso8601
        
        do {
            let result = try await dataLoader.fetch(EndPoint.searchIssues(matching: searchText), decode: { json -> Issues? in
                guard let feedResult = json as? Issues else { return  nil }
                return feedResult
            })
            
            isFetching = false
            switch result {
                case .success(let issues):
                    self.issues = issues
                    self.reloadTableView?()
                    
                case .failure(let error):
                    showError?(error)
            }
            
        } catch  {
            print("searchIssues error \(error)")
        }
    }
}

// MARK: - loadNextPage
extension SearchViewModel {
    func loadNextPage() {
        
        if isFetching {
            return
        }
        
        if canFetchMore == false {
            return
        }
        
        isFetching = true
        dataLoader.request(EndPoint.search(matching: searchText, numberOfPage: currentPage)) { [weak self] result in
            
            self?.isFetching = false
            
            switch result {
                case .success(let repo):
                    
                    guard var new = self?.repo  else {
                        return
                    }
              
                    new.total_count = repo.total_count
                    new.incomplete_results = repo.incomplete_results
                    new.license = repo.license
                    if (repo.items.count > 0) {
                        for index in 0...repo.items.count - 1 {
                            if !new.items.contains(repo.items[index]) {
                                new.items.append(repo.items[index])
                            }
                        }
                    } else {
                        self?.canFetchMore = false
                    }
                
                    if new.total_count == new.items.count {
                        self?.canFetchMore = false
                    }
                    
                    if new.items.count < 30 {
                        self?.canFetchMore = false
                    } else {
                        
                        guard let page = self?.currentPage else {
                            return
                        }
                        
                        self?.currentPage = page + 1
                    }
                    
                    self?.repo = new
                    self?.reloadTableView?()
                    
                case .failure(let error):
                    self?.showError?(error)
            }
        }
    }
}
