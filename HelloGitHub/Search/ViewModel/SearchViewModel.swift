//
//  SearchViewModel.swift
//  HelloGitHub
//
//  Created by 雲端開發部-廖彥勛 on 2021/12/27.
//

import UIKit

class SearchViewModel {
    var repo: Repositories!
    private let dataLoader: DataLoader
    var reloadTableView: (() -> Void)?
    
    var searchText: String!
    private(set) var isFetching = false
    private var canFetchMore = true
    
    var perPage: Int = 30
    var currentPage: Int = 2

    init(dataLoader: DataLoader) {
        self.dataLoader = dataLoader
    }

    func querySearch(query: String) {
        
        if isFetching {
            return
        }
        
        searchText = query
        
        isFetching = true
        
        dataLoader.request(EndPoint.search(matching: query)) { [weak self] result in
            
            switch result {
                case .success(let repo):
                
                    self?.isFetching = false
                    self?.repo = repo
                    self?.reloadTableView?()
                    
                case .failure(let error):
                    self?.isFetching = false
                    switch error {
                        case .statusCodeError(let code):
                            print(code)
                        default:
                            print(error)
                    }
            }
        }
    }
    
    func loadNextPage() {
        
        if isFetching {
            return
        }
        
        if canFetchMore == false {
            return
        }
        
        isFetching = true
        dataLoader.request(EndPoint.search(matching: searchText, numberOfPage: currentPage)) { [weak self] result in
            
            switch result {
                case .success(let repo):
                self?.isFetching = false
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
                    self?.isFetching = false
                    switch error {
                        case .statusCodeError(let code):
                            print(code)
                        default:
                            print(error)
                    }
            }
        }
    }
    
    func reset() {
        isFetching = false
        canFetchMore = true
        currentPage = 2
    }
}
