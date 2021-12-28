//
//  EndPoint.swift
//  HelloGitHub
//
//  Created by 雲端開發部-廖彥勛 on 2021/12/27.
//

import Foundation

enum RepositoriesSorting: String {
    case create
    case indexed
    case author_date = "author-date"
    case committer_date = "committer-date"
}

enum SearchRepositoriesSort: String{
    case stars
    case forks
    case updated
}

enum SearchCommitsSort: String{
    case authorDate = "author-date"
    case committerDate = "committer-date"
}

enum SearchCodeSort: String{
    case bestMatch = "best-match"
    case recentlyIndexed = "recently-indexed"
    case leastRecentlyIndexed = "least-recently-indexed"
}

enum SearchIssuesSort: String{
    case comments
    case created
    case updated
}

enum SearchUsersSort: String{
    case followers
    case repositories
    case joined
}

enum RepositoriesOrder: String {
    case asc
    case desc
}

struct EndPoint {
    static let client_id = ""
    static let client_secret = ""
    let path: String
    let queryItems: [URLQueryItem]
}

extension EndPoint {
    static func search(matching query: String,
                       sortedBy sorting: RepositoriesSorting = .create,
                       orderBy ordering: RepositoriesOrder = .asc,
                       numberOf perPage: Int = 30,
                       numberOfPage page: Int = 1) -> EndPoint {
        return EndPoint(
            path: "/search/repositories",
            queryItems: [
                URLQueryItem(name: "accept", value: "application/vnd.github.v3+json"),
                URLQueryItem(name: "q", value: query),
                URLQueryItem(name: "sort", value: sorting.rawValue),
                URLQueryItem(name: "order", value: ordering.rawValue),
                URLQueryItem(name: "per_page", value: String(perPage)),
                URLQueryItem(name: "page", value: String(page)),
            ]
        )
    }
    
    static func searchCode(matching query: String,
                       sortedBy sorting: RepositoriesSorting = .indexed,
                       orderBy ordering: RepositoriesOrder = .asc,
                       numberOf perPage: Int = 30,
                       numberOfPage page: Int = 1) -> EndPoint {
        return EndPoint(
            path: "/search/code",
            queryItems: [
                URLQueryItem(name: "accept", value: "application/vnd.github.v3+json"),
                URLQueryItem(name: "q", value: query),
                URLQueryItem(name: "sort", value: sorting.rawValue),
                URLQueryItem(name: "order", value: ordering.rawValue),
                URLQueryItem(name: "per_page", value: String(perPage)),
                URLQueryItem(name: "page", value: String(page)),
            ]
        )
    }
    
    static func searchCommits(matching query: String,
                       sortedBy sorting: RepositoriesSorting = .author_date,
                       orderBy ordering: RepositoriesOrder = .asc,
                       numberOf perPage: Int = 30,
                       numberOfPage page: Int = 1) -> EndPoint {
        return EndPoint(
            path: "/search/commits",
            queryItems: [
                URLQueryItem(name: "accept", value: "application/vnd.github.v3+json"),
                URLQueryItem(name: "q", value: query),
                URLQueryItem(name: "sort", value: sorting.rawValue),
                URLQueryItem(name: "order", value: ordering.rawValue),
                URLQueryItem(name: "per_page", value: String(perPage)),
                URLQueryItem(name: "page", value: String(page)),
            ]
        )
    }
}

extension EndPoint {
    var url: URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.github.com"
        components.path = path
        components.queryItems = queryItems
        return components.url
    }
}
