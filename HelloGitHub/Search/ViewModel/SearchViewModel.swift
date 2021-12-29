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
    var users: Users!
    var usersInfo = [UsersInfo]()
    
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
            case .people:
                Task {
                    await searchUserAndFetchInfo()
                }
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
            
                    if repo.incomplete_results {
                        showError?(NetworkError.queryTimeLimit)
                        return
                    }
                    
                    self.repo = repo
                    self.reloadTableView?()
                    
                case .failure(let error):
                    showError?(error)
            }
            
        }  catch  {
            print("searchRepositories error \(error)")
        }
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
                
                    if issues.incomplete_results {
                        showError?(NetworkError.queryTimeLimit)
                        return
                    }
                
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

// MARK: - Search Users
extension SearchViewModel {
    
    func searchUserAndFetchInfo() async {
        dataLoader.decoder.dateDecodingStrategy = .iso8601
        self.users = await fetchUser()
        await fetchUserInfo()
    }
    
    func fetchUser() async -> Users? {
        
        do {
            let result = try await dataLoader.fetch(EndPoint.searchUsers(matching: searchText), decode: { json -> Users? in
                guard let feedResult = json as? Users else { return  nil }
                return feedResult
            })

            return try result.get()
            
        } catch  {
            return nil
        }
    }
    
    func fetchUserInfo() async {
        
        do {
            try await withThrowingTaskGroup(of: (UsersInfo).self) { group -> Void in
                for index in 0...self.users.items.count - 1 {
                    guard let url = self.users.items[index].url, let metadataUrl = URL(string: url) else {
                        continue
                    }

                    group.addTask {
                        if #available(iOS 15.0, *) {
                            let metadata = try await self.dataLoader.fetchUserInfo(metadataUrl)
                            return metadata
                        } else {
                            // Fallback on earlier versions
                            let metadata = try await self.dataLoader.fetch(metadataUrl, decode: { json -> UsersInfo? in
                                guard let feedResult = json as? UsersInfo else { return  nil }
                                return feedResult
                            })
                            return try metadata.get()
                        }
                        
                    }
                    
                    for try await result in group {
                        self.usersInfo.append(result)
                    }
                }
                
                print("userInfo \(self.usersInfo)")
                self.reloadTableView?()
            }
        } catch  {
            print("Failed to load UsersInfo: \(error)")
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
