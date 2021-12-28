//
//  SearchType.swift
//  HelloGitHub
//
//  Created by 雲端開發部-廖彥勛 on 2021/12/28.
//

import Foundation

struct SearchResults: Codable {
    enum SearchType: Codable {
        case repositories
        case code
        case commits
        case issues
        case labels
        case topics
        case users
    }
}

extension SearchResults.SearchType: CaseIterable { }

extension SearchResults.SearchType: RawRepresentable {
    typealias RawValue = String

    init?(rawValue: RawValue) {
        switch rawValue {
            case "Repositories": self = .repositories
            case "Code": self = .code
            case "Commits": self = .commits
            case "Issues": self = .issues
            case "Labels": self = .labels
            case "Topics": self = .topics
            case "Users": self = .users
            default: return nil
        }
    }

    var rawValue: RawValue {
        switch self {
            case .repositories: return "Repositories"
            case .code: return "Code"
            case .commits: return "Commits"
            case .issues: return "Issues"
            case .labels: return "Labels"
            case .topics: return "Topics"
            case .users: return "Users"
        }
    }
}
