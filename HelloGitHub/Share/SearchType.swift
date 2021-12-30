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
        case issues
        case PRs
        case people
        case organizations
    }
}

extension SearchResults.SearchType: CaseIterable { }

extension SearchResults.SearchType: RawRepresentable {
    typealias RawValue = String

    init?(rawValue: RawValue) {
        switch rawValue {
            case "Repo": self = .repositories
            case "Issues": self = .issues
            case "PRs" : self = .PRs
            case "People": self = .people
            case "Org": self = .organizations
            default: return nil
        }
    }

    var rawValue: RawValue {
        switch self {
            case .repositories: return "Repo"
            case .issues: return "Issues"
            case .PRs: return "PRs"
            case .people: return "People"
            case .organizations: return "Org"
        }
    }
}
