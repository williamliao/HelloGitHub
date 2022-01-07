//
//  EndPoint.swift
//  HelloGitHub
//
//  Created by 雲端開發部-廖彥勛 on 2021/12/27.
//

import Foundation

enum SearchRepositoriesSort: String {
    case stars
    case forks
    case updated
    case helpWantedIssues = "help-wanted-issues"
}

enum SearchCommitsSort: String {
    case authorDate = "author-date"
    case committerDate = "committer-date"
}

enum SearchCodeSort: String {
    case indexed
    case recentlyIndexed = "recently-indexed"
    case leastRecentlyIndexed = "least-recently-indexed"
}

enum SearchIssuesSort: String {
    case comments
    case created
    case updated
}

enum SearchUsersSort: String{
    case followers
    case repositories
    case joined
}

enum SearchOrder: String {
    case asc
    case desc
}

struct EndPoint {
    let path: String
    let queryItems: [URLQueryItem]
}

extension EndPoint {
    static func search(matching query: String,
                       sortedBy sorting: SearchRepositoriesSort = .updated,
                       orderBy ordering: SearchOrder = .asc,
                       numberOf perPage: Int = 30,
                       numberOfPage page: Int = 1) -> EndPoint {
        return EndPoint(
            path: "/search/repositories",
            queryItems: [
                URLQueryItem(name: "q", value: query),
                URLQueryItem(name: "sort", value: sorting.rawValue),
                URLQueryItem(name: "order", value: ordering.rawValue),
                URLQueryItem(name: "per_page", value: String(perPage)),
                URLQueryItem(name: "page", value: String(page)),
            ]
        )
    }
    
    static func searchCode(matching query: String,
                       sortedBy sorting: SearchCodeSort = .indexed,
                       orderBy ordering: SearchOrder = .asc,
                       numberOf perPage: Int = 30,
                       numberOfPage page: Int = 1) -> EndPoint {
        return EndPoint(
            path: "/search/code",
            queryItems: [
                URLQueryItem(name: "q", value: query),
                URLQueryItem(name: "sort", value: sorting.rawValue),
                URLQueryItem(name: "order", value: ordering.rawValue),
                URLQueryItem(name: "per_page", value: String(perPage)),
                URLQueryItem(name: "page", value: String(page)),
            ]
        )
    }
    
    static func searchCommits(matching query: String,
                       sortedBy sorting: SearchCommitsSort = .authorDate,
                       orderBy ordering: SearchOrder = .asc,
                       numberOf perPage: Int = 30,
                       numberOfPage page: Int = 1) -> EndPoint {
        return EndPoint(
            path: "/search/commits",
            queryItems: [
                URLQueryItem(name: "q", value: query),
                URLQueryItem(name: "sort", value: sorting.rawValue),
                URLQueryItem(name: "order", value: ordering.rawValue),
                URLQueryItem(name: "per_page", value: String(perPage)),
                URLQueryItem(name: "page", value: String(page)),
            ]
        )
    }
    
    static func searchIssues(matching query: String,
                       sortedBy sorting: SearchIssuesSort = .created,
                       orderBy ordering: SearchOrder = .desc,
                       numberOf perPage: Int = 30,
                       numberOfPage page: Int = 1) -> EndPoint {
        return EndPoint(
            path: "/search/issues",
            queryItems: [
                URLQueryItem(name: "q", value: query),
                URLQueryItem(name: "sort", value: sorting.rawValue),
                URLQueryItem(name: "order", value: ordering.rawValue),
                URLQueryItem(name: "per_page", value: String(perPage)),
                URLQueryItem(name: "page", value: String(page)),
            ]
        )
    }
    
    static func searchUsers(matching query: String,
                       sortedBy sorting: SearchUsersSort = .followers,
                       orderBy ordering: SearchOrder = .desc,
                       numberOf perPage: Int = 10,
                       numberOfPage page: Int = 1) -> EndPoint {
        return EndPoint(
            path: "/search/users",
            queryItems: [
                URLQueryItem(name: "q", value: query),
                URLQueryItem(name: "sort", value: sorting.rawValue),
                URLQueryItem(name: "order", value: ordering.rawValue),
                URLQueryItem(name: "per_page", value: String(perPage)),
                URLQueryItem(name: "page", value: String(page)),
            ]
        )
    }
    
    static func fetchUsers() -> EndPoint {
        return EndPoint(
            path: "/user",
            queryItems: [URLQueryItem]()
        )
    }
    
    static func fetchStarred(name: String) -> EndPoint {
        return EndPoint(
            path: "/users/\(name)/starred",
            queryItems: [
                URLQueryItem(name: "per_page", value: "1"),
            ]
        )
    }
    
    static func fetchOrganizations(name: String) -> EndPoint {
        return EndPoint(
            path: "/users/\(name)/orgs",
            queryItems: [
                URLQueryItem(name: "per_page", value: "1"),
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

struct LoginEndPoint {
    static let client_id = "Iv1.6e411d9570d13fa3"
    static let client_secret = "f11de92814894e871402db35e7347c69a4bb7cd4"
    let path: String
    let queryItems: [URLQueryItem]
}

extension LoginEndPoint {
    static func login(redirect redirectURI: String, state codeVerifier: String) -> LoginEndPoint {
        return LoginEndPoint(
            path: "/login/oauth/authorize",
            queryItems: [
                URLQueryItem(name: "client_id", value: client_id),
                URLQueryItem(name: "redirect_uri", value: redirectURI),
                URLQueryItem(name: "state", value: codeVerifier),
            ]
        )
    }
    
    static func accessToken(received code: String, redirect redirectURI: String, state codeVerifier: String) -> LoginEndPoint {
        return LoginEndPoint(
            path: "/login/oauth/access_token",
            queryItems: [
                URLQueryItem(name: "client_id", value: client_id),
                URLQueryItem(name: "client_secret", value: client_secret),
                URLQueryItem(name: "redirect_uri", value: redirectURI),
                URLQueryItem(name: "code", value: code),
                URLQueryItem(name: "state", value: codeVerifier),
            ]
        )
    }
    
    static func refreshToken(received token: String) -> LoginEndPoint {
        return LoginEndPoint(
            path: "/login/oauth/access_token",
            queryItems: [
                URLQueryItem(name: "client_id", value: client_id),
                URLQueryItem(name: "client_secret", value: client_secret),
                URLQueryItem(name: "grant_type", value: "refresh_token"),
                URLQueryItem(name: "refresh_token", value: token),
            ]
        )
    }
}

extension LoginEndPoint {
    var url: URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "github.com"
        components.path = path
        components.queryItems = queryItems
        return components.url
    }
    
    var tokenUrl: URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "github.com"
        components.path = path
        return components.url
    }
    
    var query: String? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "github.com"
        components.path = path
        components.queryItems = queryItems
        return components.query
    }
}
