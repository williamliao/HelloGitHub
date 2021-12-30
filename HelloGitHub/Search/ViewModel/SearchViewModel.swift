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
    var finishedHandleNextPageUser: (() -> Void)?

    var searchType: SearchResults.SearchType = .repositories
    
    private let dataLoader: DataLoader
    private var searchText: String!
    private(set) var isFetching = false
    private var canFetchMore = true
    
    private var perPage: Int = 30
    private var currentPage: Int = 0
    
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
                    await searchRepositories(page: 1)
                }
            case .issues:
                Task {
                    await searchIssues(page: 1)
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
        currentPage = 0
    }
}

// MARK: - Search By Type
extension SearchViewModel {
    func searchRepositories(page: Int) async {

        dataLoader.decoder.dateDecodingStrategy = .iso8601
        
        do {
            let result = try await dataLoader.fetch(EndPoint.search(matching: searchText, numberOfPage: page), decode: { json -> Repositories? in
                guard let feedResult = json as? Repositories else { return  nil }
                return feedResult
            })
            
            isFetching = false
            switch result {
                case .success(let repo):
                
                    if page == 1 {
                        if repo.incomplete_results {
                            showError?(NetworkError.queryTimeLimit)
                            return
                        }
                        
                        self.repo = repo
                        self.reloadTableView?()
                    } else {
                        handleSearchRepositoriesNextPage(newRepo: repo)
                    }
            
                case .failure(let error):
                    showError?(error)
            }
            
        }  catch  {
            print("searchRepositories error \(error)")
        }
    }
    
    func searchIssues(page: Int) async {
        
        dataLoader.decoder.dateDecodingStrategy = .iso8601
        
        do {
            let result = try await dataLoader.fetch(EndPoint.searchIssues(matching: searchText, numberOfPage: page), decode: { json -> Issues? in
                guard let feedResult = json as? Issues else { return  nil }
                return feedResult
            })
            
            isFetching = false
            switch result {
                case .success(let issues):
                
                    if page == 1 {
                        if issues.incomplete_results {
                            showError?(NetworkError.queryTimeLimit)
                            return
                        }
                        
                        self.issues = issues
                        self.reloadTableView?()
                    } else {
                        handleSearchIssuesNextPage(newIssues: issues)
                    }
                
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
        currentPage = currentPage + 1
        //print("Will fetchUser")
        await fetchUser(page: currentPage)
        //print("Has fetchUser")
        //print("Will fetchUserInfo metadata")
        await fetchUserInfo()
        //print("Has fetchUserInfo metadata")
    }
    
    func fetchUser(page: Int) async {
        
        do {
            let result = try await dataLoader.fetch(EndPoint.searchUsers(matching: searchText, numberOfPage: page), decode: { json -> Users? in
                guard let feedResult = json as? Users else { return  nil }
                return feedResult
            })
            
            if page == 1 {
                self.users = try result.get()
            } else {
                let newUsers = try result.get()
                guard var totalUsers = self.users  else {
                    return
                }
          
               /* totalUsers.total_count = newUsers.total_count
                totalUsers.incomplete_results = newUsers.incomplete_results
                if (newUsers.items.count > 0) {
                    for index in 0...newUsers.items.count - 1 {
                        if !totalUsers.items.contains(newUsers.items[index]) {
                            totalUsers.items.append(newUsers.items[index])
                        }
                    }
                } else {
                    self.canFetchMore = false
                }
                
                if totalUsers.items.count < 30 {
                    self.canFetchMore = false
                } else {
                   
                    self.currentPage = self.currentPage + 1
                }
                
                self.users = totalUsers
                
                if self.users.items.count == newUsers.total_count {
                    self.canFetchMore = false
                }
                print(self.users.items.count)*/
                
                totalUsers.total_count = newUsers.total_count
                totalUsers.incomplete_results = newUsers.incomplete_results
                totalUsers.items.append(contentsOf: newUsers.items)
                self.users = totalUsers
            }
            
        } catch  {
            
        }
    }
    
    func fetchUserInfo() async {
        
        self.usersInfo = [UsersInfo]()
        
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
                
                //print("userInfo \(self.usersInfo)")
                isFetching = false
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
        
        switch searchType {
            case .repositories:
                Task {
                    await searchRepositories(page: currentPage)
                }
            case .issues:
                Task {
                    await searchIssues(page: currentPage)
                }
            case .people:
                Task {
                    await searchUserAndFetchInfo()
                }

            default:
                break
        }
    }
    
    func handleSearchRepositoriesNextPage(newRepo: Repositories) {
        guard var totalRepo = self.repo  else {
            return
        }
  
        totalRepo.total_count = newRepo.total_count
        totalRepo.incomplete_results = newRepo.incomplete_results
        totalRepo.license = newRepo.license
        if (newRepo.items.count > 0) {
            for index in 0...newRepo.items.count - 1 {
                if !totalRepo.items.contains(newRepo.items[index]) {
                    totalRepo.items.append(newRepo.items[index])
                }
            }
        } else {
            self.canFetchMore = false
        }
        
        if totalRepo.items.count < 30 {
            self.canFetchMore = false
        } else {
           
            self.currentPage = self.currentPage + 1
        }
        
        self.repo = totalRepo
        
        if self.repo.items.count == newRepo.total_count {
            self.canFetchMore = false
        }
        
        self.reloadTableView?()
    }
    
    func handleSearchIssuesNextPage(newIssues: Issues) {
        guard var totalIssues = self.issues  else {
            return
        }
  
        totalIssues.total_count = newIssues.total_count
        totalIssues.incomplete_results = newIssues.incomplete_results
        if (newIssues.items.count > 0) {
            for index in 0...newIssues.items.count - 1 {
                if !totalIssues.items.contains(newIssues.items[index]) {
                    totalIssues.items.append(newIssues.items[index])
                }
            }
        } else {
            self.canFetchMore = false
        }
        
        if totalIssues.items.count < 30 {
            self.canFetchMore = false
        } else {
           
            self.currentPage = self.currentPage + 1
        }
        
        self.issues = totalIssues
        
        if self.repo.items.count == newIssues.total_count {
            self.canFetchMore = false
        }
        
        self.reloadTableView?()
    }
    
    func handleSearchUsersNextPage(newUsers: Users) {
        guard var totalUsers = self.users  else {
            return
        }
  
        totalUsers.total_count = repo.total_count
        totalUsers.incomplete_results = repo.incomplete_results
        if (newUsers.items.count > 0) {
            for index in 0...newUsers.items.count - 1 {
                if !totalUsers.items.contains(newUsers.items[index]) {
                    totalUsers.items.append(newUsers.items[index])
                }
            }
        } else {
            self.canFetchMore = false
        }
        
        if totalUsers.items.count < 30 {
            self.canFetchMore = false
        } else {
           
            self.currentPage = self.currentPage + 1
        }
        
        self.users = totalUsers
        
        if self.repo.items.count == newUsers.total_count {
            self.canFetchMore = false
        }
        
        self.finishedHandleNextPageUser?()
    }
}
