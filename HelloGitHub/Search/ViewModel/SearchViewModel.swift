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
    
    var downloadAndShowTask: Task<Void, Never>? {
        didSet {
            if downloadAndShowTask == nil {
                self.reloadTableView?()
            } else {
                //do cancel Action
            }
        }
    }
    
    init(dataLoader: DataLoader) {
        self.dataLoader = dataLoader
    }
  
    // MARK: - Public
    func querySearch(query: String) {
        avoidMulitCall()
        searchText = query
        searchByType()
    }
    
    func loadNextPage() {
        avoidMulitCall()
        searchByType()
    }
    
    
    func reset() {
        isFetching = false
        canFetchMore = true
        currentPage = 0
    }
}

// MARK: - Search Repositories
extension SearchViewModel {
    
    func searchRepositoriesTask() {
        downloadAndShowTask = Task.init(priority: .background) {
            dataLoader.decoder.dateDecodingStrategy = .iso8601
            currentPage = currentPage + 1
            if #available(iOS 15.0.0, *) {
                await searchRepositories(page: currentPage)
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    func searchRepositories(page: Int) async {

        dataLoader.decoder.dateDecodingStrategy = .iso8601
        
        do {
            let result = try await dataLoader.fetch(EndPoint.search(matching: searchText, numberOfPage: page), decode: { [self] json -> Repositories? in
                isFetching = false
                guard let feedResult = json as? Repositories else { return  nil }
                return feedResult
            })
            
            switch result {
                case .success(let repo):
                
                    if repo.incomplete_results {
                        showError?(NetworkError.queryTimeLimit)
                        return
                    }
                
                    if page == 1 {
                        self.repo = repo
                        downloadAndShowTask = nil
                    } else {
                        handleSearchRepositoriesNextPage(newRepo: repo)
                    }
            
                case .failure(let error):
                    print("searchRepositories \(error)")
                    showError?(error)
            }
            
        }  catch  {
            isFetching = false
            print("searchRepositories error \(error)")
            showError?(error as? NetworkError ?? NetworkError.unKnown)
        }
    }
    
    
}

// MARK: - Search Issues
extension SearchViewModel {
    
    func searchIssuesTask() {
        downloadAndShowTask = Task.init(priority: .background) {
            dataLoader.decoder.dateDecodingStrategy = .iso8601
            currentPage = currentPage + 1
            await searchIssues(page: currentPage)
        }
    }
    
    func searchIssues(page: Int) async {
        
        dataLoader.decoder.dateDecodingStrategy = .iso8601
        
        if page == 1 {
            if (searchType == .issues) {
                searchText = searchText.appending("+type:issue")
            } else if (searchType == .PRs) {
                searchText = searchText.appending("+type:pr")
            }
        }
        
        do {
            let result = try await dataLoader.fetch(EndPoint.searchIssues(matching: searchText, numberOfPage: page), decode: { [self] json -> Issues? in
                isFetching = false
                guard let feedResult = json as? Issues else { return  nil }
                return feedResult
            })
            
            switch result {
                case .success(let issues):
                
                    if issues.incomplete_results {
                        showError?(NetworkError.queryTimeLimit)
                        return
                    }
                
                    if page == 1 {
                        self.issues = issues
                        downloadAndShowTask = nil
                    } else {
                        handleSearchIssuesNextPage(newIssues: issues)
                    }
                
                case .failure(let error):
                    print("searchIssues \(error)")
                    showError?(error)
            }
            
        } catch  {
            isFetching = false
            print("searchIssues error \(error)")
            showError?(error as? NetworkError ?? NetworkError.unKnown)
        }
    }
}

// MARK: - Search Users
extension SearchViewModel {
    
    func searchUserAndFetchInfo() {
        
        downloadAndShowTask = Task.init(priority: .background) {
            dataLoader.decoder.dateDecodingStrategy = .iso8601
            currentPage = currentPage + 1
            //print("Will fetchUser")
            async let _ = await fetchUser(page: currentPage)
            //print("Has fetchUser")
            //print("Will fetchUserInfo metadata")
            async let _ = await fetchUserInfo()
            //print("Has fetchUserInfo metadata")
            isFetching = false
            downloadAndShowTask = nil
        }
    }
    
    func fetchUser(page: Int) async {
        
        if page == 1 {
            if (searchType == .organizations) {
                searchText = searchText.appending("+type:org")
            } else if (searchType == .people) {
                searchText = searchText.appending("+type:user")
            }
        }
        
        do {
            let result = try await dataLoader.fetch(EndPoint.searchUsers(matching: searchText, numberOfPage: page), decode: { json -> Users? in
                guard let feedResult = json as? Users else { return  nil }
                return feedResult
            })
            
            switch result {
                case .success(let user):
                
                    if user.incomplete_results {
                        showError?(NetworkError.queryTimeLimit)
                        return
                    }
                    
                    if page == 1 {
                        self.users = user
                        downloadAndShowTask = nil
                    } else {
                        handleSearchUsersNextPage(newUsers: user)
                    }
                
                case .failure(let error):
                    showError?(error)
                    print("fetchUser \(error)")
                    
            }
            
        } catch  {
            isFetching = false
            showError?(error as? NetworkError ?? NetworkError.unKnown)
            downloadAndShowTask = nil
        }
    }
    
    func fetchUserInfo() async {
        
        guard let user = self.users else {
            return
        }
        
        self.usersInfo = [UsersInfo]()
        var urls = [URL]()
        
        urls = user.items.compactMap { item in
            let path = item.url!
            return URL(string: path)
        }
            
        if #available(iOS 15.0, *) {
            
            do {
                
                for try await info in RemoteDataAsyncSequence(urls: urls, urlSession: URLSession.shared) {
                    self.usersInfo.append(info)
                }
                
            } catch {
                isFetching = false
                print("fetchUserInfo \(error)")
                downloadAndShowTask = nil
                
                let networkError = error as? NetworkError ?? NetworkError.unKnown
                
                switch networkError {
                    case .invalidToken:
                        showError?(NetworkError.invalidToken)
                    default:
                        showError?(error as? NetworkError ?? NetworkError.unKnown)
                }
            }
            
        } else {
            
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
                    
                    isFetching = false
                    downloadAndShowTask = nil
                }
            } catch  {
                isFetching = false
                downloadAndShowTask = nil
                let networkError = error as? NetworkError ?? NetworkError.unKnown
                
                switch networkError {
                    case .invalidToken:
                        showError?(NetworkError.invalidToken)
                    default:
                        showError?(error as? NetworkError ?? NetworkError.unKnown)
                }
            }
        }
    }
}

// MARK: - Search Organizations
extension SearchViewModel {
    
    func searchOrganizationsAndFetchInfo() {
        
        downloadAndShowTask = Task.init(priority: .background) {
            dataLoader.decoder.dateDecodingStrategy = .iso8601
            currentPage = currentPage + 1
            //print("Will fetchUser")
            async let _ = await fetchUser(page: currentPage)
            //print("Has fetchUser")
            //print("Will fetchUserInfo metadata")
            async let _ = await fetchUserInfo()
            //print("Has fetchUserInfo metadata")
        }
    }
}

// MARK: - Private
extension SearchViewModel {
    
    private func avoidMulitCall() {
        if isFetching {
            return
        }
        
        isFetching = true
    }
    
    private func searchByType() {
        switch searchType {
            case .repositories:
                searchRepositoriesTask()
            case .issues, .PRs:
                searchIssuesTask()
            case .people, .organizations:
                searchUserAndFetchInfo()
        }
    }
    
    private func handleSearchRepositoriesNextPage(newRepo: Repositories) {
        guard var totalRepo = self.repo  else {
            return
        }
  
        totalRepo.total_count = newRepo.total_count
        totalRepo.incomplete_results = newRepo.incomplete_results
        totalRepo.items.append(contentsOf: newRepo.items)
        self.repo = totalRepo
        
        if totalRepo.items.count < 30 {
            self.canFetchMore = false
        }
        
        if self.repo.items.count == newRepo.total_count {
            self.canFetchMore = false
        }
        
        downloadAndShowTask = nil
    }
    
    private func handleSearchIssuesNextPage(newIssues: Issues) {
        guard var totalIssues = self.issues  else {
            return
        }
  
        totalIssues.total_count = newIssues.total_count
        totalIssues.incomplete_results = newIssues.incomplete_results
        totalIssues.items.append(contentsOf: newIssues.items)
        self.issues = totalIssues
        
        if totalIssues.items.count < 30 {
            self.canFetchMore = false
        }
        
        if self.issues.items.count == newIssues.total_count {
            self.canFetchMore = false
        }
        
        downloadAndShowTask = nil
    }
    
    private func handleSearchUsersNextPage(newUsers: Users) {
        guard var totalUsers = self.users  else {
            return
        }
  
        totalUsers.total_count = newUsers.total_count
        totalUsers.incomplete_results = newUsers.incomplete_results
        totalUsers.items.append(contentsOf: newUsers.items)
        self.users = totalUsers
        
        if totalUsers.items.count < 30 {
            self.canFetchMore = false
        }
        
        if self.users.items.count == newUsers.total_count {
            self.canFetchMore = false
        }
    }
}
